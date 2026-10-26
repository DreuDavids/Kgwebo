import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const MODEL = Deno.env.get("LITELLM_MODEL") ?? "gpt-4o-mini";
const BASE_URL =
  Deno.env.get("LITELLM_BASE_URL") ?? "https://api.litellm.ai/v1";

function systemPrompt(currencyCode: string): string {
  return `You are Ask inside Kgwebo, a business bookkeeping app.
The signed-in business records money in ${currencyCode}. Unnamed amounts are ${currencyCode}. Never convert a different named currency into ${currencyCode}.
Reply in the user's language, including Setswana mixed with English.
Return JSON only with this shape:
{"language":"en","intent":"finances"|"howto"|"drafts"|"recommendations"|"navigate"|"chat","reply":"string","chart":"totals"|"cash_path"|null,"navigate":"recordSale"|"recordExpense"|"transactions"|"products"|"cashFlow"|"recommendations"|"reports"|"dashboard"|"settings"|"businessProfile"|null,"transactions":[{"type":"sale"|"expense"|"owner_withdrawal","amount_pula":"12.50"|null,"item":string|null,"quantity":integer|null,"category":string|null,"note":string|null,"payment_status":"paid"|"unpaid"|null,"currency":"${currencyCode}"|"ZAR"|"BWP"|null}]}
Rules:
- Snapshot and book figures are the only allowed money facts. Do not add, subtract, forecast, or invent a balance.
- If the user asks about cash, sales, expenses or profit, set intent to finances, copy snapshot amounts into reply without changing them, and set chart to totals.
- If there is no snapshot, do not invent cash. The phone already answers cash, bills and stock from Kgwebo records.
- If the user describes a sale, expense, or owner withdrawal, set intent to drafts and fill transactions from the message. Multiply quantity by a unit price when they say "each". Infer payment_status paid from bought, spent, paid, rekile, or rekisitse. Infer unpaid from on credit or ka mokgele.
- amount_pula is the amount in ${currencyCode} (the field name is historical). Use null and set currency when the user named a different currency.
- Do not ask for facts the user already gave. If they asked you to record it, draft it.
- Never invent dates or product ids. You may repeat a product name from book.products. Use null for unknown fields.
- Recommendations must only restate titles provided by the app. Do not invent advice.
- category may only be goods, services, other_sale, stock, rent, transport, utilities, wages, fees, other_expense, owner_withdrawal.
- Do not write SQL. Do not claim a transaction was saved.`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }
  const userId = await requireUser(req);
  if (userId instanceof Response) {
    return userId;
  }
  const allowed = await allowRate(userId);
  if (!allowed) {
    return json({ error: "Ask is busy. Try again in a few minutes." }, 429);
  }
  const apiKey = Deno.env.get("LITELLM_API_KEY");
  if (!apiKey) {
    return json({ error: "Ask is not configured." }, 503);
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const message = String(payload.message ?? "").trim();
  if (!message) {
    return json({ error: "Message required" }, 400);
  }

  const snapshot = payload.snapshot ?? null;
  const snapshotRecord =
    snapshot && typeof snapshot === "object"
      ? (snapshot as Record<string, unknown>)
      : null;
  const currencyCode = namedCurrency(
    payload.currencyCode ?? snapshotRecord?.currencyCode,
  );
  const titles = Array.isArray(payload.recommendationTitles)
    ? payload.recommendationTitles
    : [];

  const userBlock = JSON.stringify({
    message,
    currencyCode,
    snapshot,
    book: payload.book ?? null,
    recommendationTitles: titles,
  });

  const model = await resolveModel(apiKey);
  if (!model) {
    return json(
      {
        error: "Ask could not find a model for this LiteLLM key.",
      },
      502,
    );
  }

  const llm = await fetch(chatUrl(BASE_URL), {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      temperature: 0.2,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt(currencyCode) },
        { role: "user", content: userBlock },
      ],
    }),
  });

  const raw = await llm.text();
  if (!llm.ok) {
    return json(
      {
        error: "Ask could not reach the language model.",
        llmStatus: llm.status,
        detail: sanitize(raw, apiKey),
      },
      502,
    );
  }

  let body: Record<string, unknown>;
  try {
    body = JSON.parse(raw) as Record<string, unknown>;
  } catch {
    return json({ error: "Empty model response" }, 502);
  }

  const text = isolateJson(firstContent(body));
  if (text.trim() === "") {
    return json({ error: "Empty model response" }, 502);
  }
  try {
    const parsed = JSON.parse(text);
    return json(parsed, 200);
  } catch {
    return json({ error: "Model response was not JSON" }, 502);
  }
});

async function resolveModel(apiKey: string): Promise<string | null> {
  const preferred = Deno.env.get("LITELLM_MODEL") ?? MODEL;
  const response = await fetch(modelsUrl(BASE_URL), {
    headers: { Authorization: `Bearer ${apiKey}` },
  });
  if (!response.ok) {
    return preferred;
  }
  let body: { data?: Array<{ id?: string }> };
  try {
    body = await response.json();
  } catch {
    return preferred;
  }
  const ids = (body.data ?? [])
    .map((item) => item.id)
    .filter((id): id is string => typeof id === "string" && id.length > 0);
  if (ids.length === 0) {
    return preferred;
  }
  if (ids.includes(preferred)) {
    return preferred;
  }
  const cheap = ids.find((id) => /flash|mini|haiku|small|lite/i.test(id));
  return cheap ?? ids[0];
}

function modelsUrl(base: string): string {
  const trimmed = base.trim().replace(/\/$/, "");
  if (trimmed.endsWith("/chat/completions")) {
    return `${trimmed.slice(0, -"/chat/completions".length)}/models`;
  }
  return `${trimmed}/models`;
}

function chatUrl(base: string): string {
  const trimmed = base.trim().replace(/\/$/, "");
  if (trimmed.endsWith("/chat/completions")) {
    return trimmed;
  }
  return `${trimmed}/chat/completions`;
}

function firstContent(body: Record<string, unknown>): string {
  const choices = body.choices;
  if (!Array.isArray(choices) || choices.length === 0) {
    return "";
  }
  const message = (choices[0] as { message?: { content?: unknown } }).message;
  return typeof message?.content === "string" ? message.content : "";
}

function isolateJson(raw: string): string {
  const fenced = raw.match(/```(?:json)?\s*(\{[\s\S]*?\})\s*```/i);
  if (fenced?.[1]) {
    return fenced[1];
  }
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start < 0 || end <= start) {
    return raw.trim();
  }
  return raw.slice(start, end + 1);
}

function sanitize(raw: string, apiKey: string): string {
  return raw.replaceAll(apiKey, "[redacted]").slice(0, 400);
}

async function requireUser(req: Request): Promise<string | Response> {
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.toLowerCase().startsWith("bearer ")) {
    return json({ error: "Sign in to use Ask." }, 401);
  }
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anon) {
    return json({ error: "Ask is not configured." }, 503);
  }
  const res = await fetch(`${url.replace(/\/$/, "")}/auth/v1/user`, {
    headers: { Authorization: auth, apikey: anon },
  });
  if (!res.ok) {
    return json({ error: "Sign in to use Ask." }, 401);
  }
  const body = (await res.json()) as { id?: unknown };
  if (typeof body.id !== "string" || body.id.length === 0) {
    return json({ error: "Sign in to use Ask." }, 401);
  }
  return body.id;
}

async function allowRate(userId: string): Promise<boolean> {
  const url = Deno.env.get("SUPABASE_URL");
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !service) {
    return true;
  }
  const res = await fetch(
    `${url.replace(/\/$/, "")}/rest/v1/rpc/kgwebo_touch_copilot_rate`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${service}`,
        apikey: service,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        p_user_id: userId,
        p_limit: 40,
        p_window_seconds: 600,
      }),
    },
  );
  if (!res.ok) {
    return true;
  }
  const allowed = await res.json();
  return allowed === true;
}

function namedCurrency(value: unknown): string {
  if (typeof value !== "string") {
    return "BWP";
  }
  const code = value.trim().toUpperCase();
  return /^[A-Z]{3}$/.test(code) ? code : "BWP";
}

function json(value: unknown, status: number): Response {
  return new Response(JSON.stringify(value), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
