import {pathsToModuleNameMapper} from "ts-jest";
import { compilerOptions } from './tsconfig.json';

const config =  {
  preset: "ts-jest",
  testTimeout: 30000, // quite long - add timeout to specific tests.
  testEnvironment: "jsdom",
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      babel: true,
      tsconfig: "./tsconfig.jest.json"
    }],
  },
  moduleNameMapper: pathsToModuleNameMapper(compilerOptions.paths, { prefix: '<rootDir>' }),
  setupFilesAfterEnv: ['<rootDir>/jest-setup.ts'],
  coveragePathIgnorePatterns: [
    "<rootDir>/.next/",
    "<rootDir>/storyboard_static/",
    "<rootDir>/node_modules/",
    "<rootDir>/src/app/\\(pages\\)/\\(examples\\)",
    "<rootDir>/src/stories",
    "<rootDir>/src/app/\\(pages\\)/tasks/data",
    "<rootDir>/src/components/ui",
    "<rootDir>/src/components/icons.tsx",
    "<rootDir>/src/app/\\(pages\\)/test",
    "<rootDir>/src/app/(pages)/tasks/components", // unused atm
    "<rootDir>/src/middleware.ts", // to be tested by integration
  ],
  modulePathIgnorePatterns: ['node_modules', 'jest-test-results.json'],
  collectCoverageFrom: [
    "src/**/*.{js,jsx,ts,tsx}",
    "!<rootDir>/node_modules/"
  ],
  coverageThreshold: {
    "global": {
      "lines": 90,
      "statements": 90
    }
  },
};

export default config;