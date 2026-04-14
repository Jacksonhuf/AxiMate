/**
 * AxiMate Ripple (desktop) vs upstream CoPaw branding.
 * Default on in this tree; set VITE_RIPPLE_DESKTOP=0 to use CoPaw PNG logos.
 */
export const isRippleDesktop = import.meta.env.VITE_RIPPLE_DESKTOP === "1";

/** User-facing app name in window title, alt text, shell UI, and chat assistant label */
export const appDisplayName = isRippleDesktop ? "AxiMate Ripple" : "CoPaw";
export const appShortName = isRippleDesktop ? "AxiMate Ripple" : "CoPaw";

/** Attribution link target (UI copy avoids the name; see locales `legal.*`). */
export const upstreamProjectName = "CoPaw";
export const upstreamProjectUrl = "https://github.com/agentscope-ai/CoPaw";
export const apacheLicenseUrl = "https://www.apache.org/licenses/LICENSE-2.0";
