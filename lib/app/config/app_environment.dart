/// Deployed or local environment name from `APP_ENV`.
enum AppEnvironment { development, staging, production, demo }

/// How the app should treat data for the current process.
///
/// [live] means backend credentials are present and a Supabase client session
/// may be opened.
///
/// [local] means required backend config is missing. The UI is labelled and
/// never filled with demo figures. No Supabase session is opened.
///
/// [demo] is an explicit `APP_ENV=demo` choice, never a silent fallback. It
/// never writes to a real account.
enum AppRuntimeMode { live, local, demo }
