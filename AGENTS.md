# AGENTS.md

`react-native-get-location` is a React Native library (Android + iOS) that returns the device's current position once. Public API: `GetLocation.getCurrentPosition({enableHighAccuracy, timeout, rationale?})` -> `Promise<Location>`, `GetLocation.openSettings()`, `LocationError` and `isLocationError`. It is a TurboModule (New Architecture) with an old-architecture fallback. Usage, option and field tables live in `README.md`; do not duplicate them here.

## Prerequisites

- Node >= 22.11 (`engines`), Yarn **1.x** (both lockfiles are `yarn.lock` v1).
- **Yarn 1 only:** both `package.json` files pin `"packageManager": "yarn@1.22.22"`, so Corepack selects Yarn 1 automatically. Check `yarn -v` prints `1.22.22` before installing; a Yarn 4 install silently migrates `yarn.lock` to Berry/PnP. Revert any unintended `yarn.lock` / `.pnp.cjs` / `.yarnrc.yml` / `.yarn/` changes.
- iOS (Sample): Ruby >= 2.6.10 (see `Sample/Gemfile`; works on 3.4), Bundler, CocoaPods >= 1.13 (not 1.15.0/1.15.1), Xcode. Library pod targets iOS 14.0 (`ReactNativeGetLocation.podspec`).
- Android (Sample): JDK 17+ and Android SDK (library `minSdkVersion` default 24, `compileSdk` default 35; Sample uses compileSdk 37). The repo does not pin a JDK.
- `peerDependencies.react-native` is `>=0.80` because `src/specs/NativeRNGetLocation.ts` uses `import type {CodegenTypes} from 'react-native'`, which exists only from RN 0.80.

## Commands

Run from the repo root unless noted.

```sh
yarn install                       # root deps (Yarn 1)
node_modules/.bin/tsc              # build to dist/ (same as `yarn build`); delete dist/ afterwards, never commit it
node_modules/.bin/tsc --noEmit     # typecheck only
node_modules/.bin/eslint src       # lint library (config: @react-native)

cd Sample
yarn install                       # Sample deps; installs the lib as a COPY from ../
node_modules/.bin/tsc --noEmit
node_modules/.bin/eslint .
node_modules/.bin/jest             # only __tests__/App.test.tsx exists
yarn start                         # Metro
yarn android                       # builds Android (native build, slow)
bundle install && cd ios && bundle exec pod install && cd ..   # iOS pods
yarn ios
```

There are no unit tests for the library or the native code; native behavior is verified by running the Sample on a device/simulator. The Sample has New Architecture on (`newArchEnabled=true` in `Sample/android/gradle.properties`, `ENV['RCT_NEW_ARCH_ENABLED'] = '1'` in `Sample/ios/Podfile`).

## Repository map

- `src/index.ts`: public API. Merges defaults (`enableHighAccuracy: false`, `timeout: 60000`), requests Android permission, calls the native module, rewraps native errors in `LocationError`.
- `src/specs/NativeRNGetLocation.ts`: TurboModule spec and the `Location` / `NativeOptions` types; codegen input (`package.json#codegenConfig`: name `rngetlocation_codegen`, Android package `com.github.douglasjunior.reactNativeGetLocation`, iOS provider `RNGetLocation` -> `RNGetLocationTurbo`).
- `src/LocationError.ts`: `LocationError`, `LocationErrorCode`, `isLocationError`. `src/utils.ts`: Android permission check/request (`ACCESS_FINE_LOCATION` if `enableHighAccuracy`, else `ACCESS_COARSE_LOCATION`).
- `android/src/main/java/com/github/douglasjunior/reactNativeGetLocation/`: `ReactNativeGetLocationImpl.java` (holds the in-flight request, cancels the previous one), `util/GetLocation.java` (`LocationManager` + `Criteria` + `Timer`; builds the result map), `ReactNativeGetLocationPackage.java`.
- `android/src/newarch/.../modules/` and `android/src/oldarch/.../modules/`: two `ReactNativeGetLocationModule.java`; `android/build.gradle` adds exactly one source dir depending on `newArchEnabled`.
- `ios/ReactNativeGetLocationLibrary/`: `LocationModuleImpl.m` (CLLocationManager, NSTimer timeout, authorization flow, result dictionary), `LocationModule.m` (old-arch bridge, `#else` branch), `RNGetLocationTurbo.mm` (new-arch bridge, under `#ifdef RCT_NEW_ARCH_ENABLED`). `ReactNativeGetLocation.podspec` globs `ios/ReactNativeGetLocationLibrary/**/*.{h,m,mm,swift}`; it calls `install_modules_dependencies` when `RCT_NEW_ARCH_ENABLED=1`, else depends on `React-Core`.
- `Sample/`: RN 0.88.1 demo app (`App.tsx`), consumes the lib via `"react-native-get-location": "file:../"`.
- `.github/workflows/publish.yml`: release automation. `docs/`, `DEPENDENTS.md`, `*.svg`: README assets; leave alone.

## Call flow

JS merges defaults -> (Android only) `requestAndroidPermission` -> native `getCurrentPosition` -> native cancels any pending request (`CANCELLED`), starts updates and a timeout timer -> first fix resolves the Promise and stops updates -> JS returns the typed `Location`. Native rejections are rethrown as `LocationError(code, message)`; non-location errors pass through unchanged.

## Invariants (do not break)

- Error codes and messages are identical on JS, Android and iOS and in the README error table:
  - `CANCELLED`: `Location cancelled by user or by another request`
  - `UNAVAILABLE`: `Location service is disabled or unavailable`
  - `TIMEOUT`: `Location timed out`
  - `UNAUTHORIZED`: `Location permission denied by the user`
  - Places: `src/utils.ts`, `src/LocationError.ts` (doc comments), `android/.../util/GetLocation.java`, `ios/.../LocationModuleImpl.m`, `README.md`. A change in one requires the others. Note the `TIMEOUT` doc comment in `src/LocationError.ts` currently reads "Location request timed out"; the runtime message is the one above.
- Timeout rejects with `TIMEOUT`; `timeout <= 0` means no timer. A new request while one is pending rejects the old one with `CANCELLED`. Resolve/reject at most once, then stop updates and clear references.
- Android permission denial in JS and `SecurityException` in native both map to `UNAUTHORIZED`. On iOS, check authorization only in `locationManagerDidChangeAuthorization` / `startUpdatingLocation`; do not add duplicate checks.
- Android/iOS parity: same options, same codes, same success shape for shared fields. Platform-only `Location` fields are optional and documented as such (Android: `bearing`, `provider`, `mocked`; iOS: `verticalAccuracy`, `course`).
- Backward compatible API: never rename or remove existing options, fields or exports; new `Location` fields are optional.
- No third-party location dependencies (no Google Play Services, no fused provider); only `LocationManager` and `CLLocationManager`.
- One-shot only: no continuous watch / subscription API.
- `package.json` keeps `main` and `react-native` pointing to `src`.

## Recipes

Add a field to `Location` (optional, backward compatible):
1. Add the property to `Location` in `src/specs/NativeRNGetLocation.ts` with a doc comment (`?` and an "(Android only)" / "(iOS only)" prefix when not on both platforms).
2. Android: add it to the result map in `onLocationChanged` in `android/.../util/GetLocation.java`; guard APIs by SDK level (`minSdk` 24).
3. iOS: add it to the dictionary in `didUpdateLocations` in `ios/.../LocationModuleImpl.m`.
4. Update the `Location` table in `README.md`.
5. Validate in the Sample on both platforms with New Architecture on; add the field to `Sample/App.tsx` output if useful.

Change the TurboModule spec (`NativeOptions`, method signatures):
1. Needs human approval (public API). Edit `src/specs/NativeRNGetLocation.ts`.
2. Update both arch variants on Android (`src/newarch` and `src/oldarch` modules, plus `ReactNativeGetLocationImpl.java`/`GetLocation.java`) and both iOS bridges (`RNGetLocationTurbo.mm` and `LocationModule.m`, plus `LocationModuleImpl.m`).
3. Update `src/index.ts` defaults/types and `README.md`.
4. Re-run codegen by rebuilding the Sample (`pod install` for iOS, Gradle build for Android).

Test a library change in the Sample:
- The Sample installs the lib as a copy, so edits to `src/`, `android/` or `ios/` are not picked up. From `Sample/`, run `./install.sh` (wipes `node_modules`, `ios/Pods`, and root `node_modules`, reinstalls, strips the nested `Sample/` and `.git` from the copy, runs `npx -y pod-install`), then restart Metro with `yarn start --reset-cache`. `install.sh` uses `yarn`, so confirm Yarn 1 first.

## Boundaries

Ask a human before:
- changing the public API, the spec, option defaults, or error codes/messages;
- bumping `peerDependencies`, `engines`, minimum iOS/Android versions, or RN/React/TypeScript major versions;
- touching `.github/workflows/publish.yml` or anything about releasing.

Never:
- publish manually (`npm publish`, `yarn publish`) or restore `scripts/publish.js` (removed). Publishing is automatic: a GitHub Release with a semver tag (`1.2.3` or `v1.2.3`) triggers `.github/workflows/publish.yml`, which runs `yarn install --frozen-lockfile` and `yarn build`, sets `main`/`types` to `dist` only in the workflow workspace, publishes via npm Trusted Publishing (OIDC), uses dist-tag `next` for pre-releases, and the release bot commits `chore(release): <version> [skip ci]` back to the default branch.
- edit `version` in `package.json` or point `main`/`types` to `dist` in the repo; the workflow owns both;
- commit `dist/` (gitignored), `ios/Pods`, `vendor/bundle`, or Yarn Berry artifacts;
- edit generated/lock files by hand (`yarn.lock`, `Podfile.lock`) or run `yarn install` with Yarn 4;
- add dependencies to `dependencies` (the lib has none; keep it that way).

## Conventions

- Language: English everywhere (code, comments, commits, docs).
- Commits: Conventional Commits, matching history: `feat(android): ...`, `fix(ios): ...`, `fix: ...`, `docs: ...`, `chore(deps): ...`. The release bot owns `chore(release)`.
- Formatting: Prettier 2.8.8 (`.prettierrc.js`: single quotes, no bracket spacing, trailing commas `all`, `arrowParens: 'avoid'`); ESLint `@react-native`. Fix lint on files you touch; `src/utils.ts` and `src/LocationError.ts` contain a few lines that are not Prettier-formatted, so do not reformat unrelated lines.
- License: every `.ts`, `.java`, `.h`, `.m`, `.mm` file starts with the MIT header (copyright 2019 Douglas Nassif Roma Junior; `/** */` block in TS/Java, `//` lines in iOS). Copy it from an existing file into new files. Exception: `src/specs/NativeRNGetLocation.ts` currently has none; do not add one unless asked.
- Java source level is 1.8; keep Android code compatible with `minSdk` 24.

## Definition of done

- [ ] `node_modules/.bin/tsc` and `node_modules/.bin/eslint src` pass at the root; `dist/` removed.
- [ ] In `Sample/`: `node_modules/.bin/tsc --noEmit`, `node_modules/.bin/eslint .` and `node_modules/.bin/jest` pass (only after reinstalling the lib copy if `src/` changed).
- [ ] If native or spec code changed: Sample built and exercised on Android and iOS (success, timeout, permission denied, location off, second call cancelling the first).
- [ ] Error messages still verbatim in all five places listed under Invariants.
- [ ] README updated for any public change (Location table, options, error table).
- [ ] `git status` shows no `dist/`, no `yarn.lock` churn from Yarn 4, no version edits.
- [ ] Commit message follows Conventional Commits.
