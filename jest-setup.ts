import "@testing-library/jest-dom";
import "whatwg-fetch";
global.ResizeObserver = require("resize-observer-polyfill");

// Mock useRouter:
jest.mock("next/navigation", () => ({
  useRouter() {
    return {
      prefetch: () => null,
    };
  },
  usePathname() {
    return "";
  },
}));

// ensure we have the environment variables setup, or auto-fail all tests.
if (
  !process.env.JEST_DEFAULT_USER_EMAIL ||
  !process.env.JEST_DEFAULT_USER_PASSWORD
) {
  throw Error(
    "!process.env.JEST_DEFAULT_USER_EMAIL || !process.env.JEST_DEFAULT_USER_PASSWORD",
  );
}

if (
  !process.env.JEST_ADMIN_USER_EMAIL ||
  !process.env.JEST_ADMIN_USER_PASSWORD
) {
  throw Error(
    "!process.env.JEST_DEFAULT_USER_EMAIL || !process.env.JEST_DEFAULT_USER_PASSWORD",
  );
}

export type user_info_type = {
  name: string;
  email: string;
  password: string;
  role: string;
  roleText: string;
  number: string;
};

export const test_user_info: user_info_type = {
  name: "Integration",
  email: process.env.JEST_DEFAULT_USER_EMAIL!,
  password: process.env.JEST_DEFAULT_USER_PASSWORD!,
  role: "1",
  roleText: "Default",
  number: "1234567890",
};

export const test_admin_info: user_info_type = {
  name: "Integration Admin",
  email: process.env.JEST_ADMIN_USER_EMAIL!,
  password: process.env.JEST_ADMIN_USER_PASSWORD!,
  role: "2",
  roleText: "Administrator",
  number: "1234567890",
};

export function getCookie(name: string): string | null {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) {
    const cookieValue = parts.pop()?.split(";").shift();
    if (cookieValue) {
      return cookieValue;
    }
  }
  return null;
}

// TODO
// implement -- strip url, add "-auth-token"
// this won't work for local supabase deploy. look into it.
export function getCookieName() {
  return "sb-ciguaogfmmnxjxfqpwhp-auth-token";
}
