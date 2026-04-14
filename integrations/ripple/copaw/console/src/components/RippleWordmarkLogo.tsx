import { useId, type CSSProperties } from "react";

/**
 * AxiMate Ripple — bold **A**, stylized **x** (gradient curve), **iMate**, then **Ripple**.
 */
export default function RippleWordmarkLogo({
  isDark,
  className,
  style,
}: {
  isDark: boolean;
  className?: string;
  style?: CSSProperties;
}) {
  const rawId = useId().replace(/[^a-zA-Z0-9_-]/g, "");
  const gradId = `axi-x-grad-${rawId}`;

  const navy = isDark ? "#e2e8f0" : "#164E63";
  const navyX = isDark ? "#cbd5e1" : "#164E63";
  const g0 = isDark ? "#67e8f9" : "#CFFAFE";
  const g1 = isDark ? "#22d3ee" : "#0891B2";

  const mainSize = 23;
  const rippleSize = 15;

  return (
    <svg
      className={className}
      style={style}
      viewBox="0 0 168 28"
      role="img"
      xmlns="http://www.w3.org/2000/svg"
      aria-label="Ripple Console"
    >
      <title>Ripple Console</title>
      <defs>
        <linearGradient
          id={gradId}
          gradientUnits="userSpaceOnUse"
          x1="2.5"
          y1="13"
          x2="15.5"
          y2="3.5"
        >
          <stop offset="0%" stopColor={g0} />
          <stop offset="100%" stopColor={g1} />
        </linearGradient>
      </defs>

      <text
        x="0"
        y="21.5"
        fontFamily='system-ui, "Segoe UI", "Segoe UI Variable", sans-serif'
        fontSize={mainSize}
        fontWeight="700"
        letterSpacing="-0.03em"
        fill={navy}
      >
        A
      </text>

      <g transform="translate(11, 6)">
        <path
          d="M 2.5 13 Q 9 8 15.5 3.5"
          fill="none"
          stroke={`url(#${gradId})`}
          strokeWidth="2.1"
          strokeLinecap="round"
        />
        <path
          d="M 2.5 3.5 Q 9 8.5 15.5 13"
          fill="none"
          stroke={navyX}
          strokeWidth="2.1"
          strokeLinecap="round"
        />
      </g>

      <text
        x="29"
        y="21.5"
        fontFamily='system-ui, "Segoe UI", "Segoe UI Variable", sans-serif'
        fontSize={mainSize}
        fontWeight="700"
        letterSpacing="-0.03em"
        fill={navy}
      >
        iMate
      </text>

      <text
        x="100"
        y="21.5"
        fontFamily='system-ui, "Segoe UI", "Segoe UI Variable", sans-serif'
        fontSize={rippleSize}
        fontWeight="600"
        letterSpacing="-0.02em"
        fill={navy}
      >
        Ripple
      </text>
    </svg>
  );
}
