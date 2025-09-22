# AI Agent Instructions - react-native-get-location

1. Purpose
Single JS API `GetLocation.getCurrentPosition(options)` returning a Promise with the current device position (Android/iOS). Uses a native module (TurboModule when New Architecture is enabled). Supports: timeout, coarse/fine accuracy, unified error codes: `CANCELLED`, `UNAVAILABLE`, `TIMEOUT`, `UNAUTHORIZED` with fixed messages.

2. Core Architecture
- Public JS surface: `src/index.ts` (merges defaults, requests Android permission, wraps native error into `LocationError`).
- Spec & types for codegen: `src/specs/NativeRNGetLocation.ts` (Location + NativeOptions) referenced by `package.json#codegenConfig`.
- Error normalization: `src/LocationError.ts` + `isLocationError`.
- Android permission helper: `src/utils.ts` (fine vs coarse selection before native call).
- Android native flow: `ReactNativeGetLocationImpl.java` orchestrates; `util/GetLocation.java` requests updates (LocationManager + Criteria + Timer for timeout) and cancels previous pending request.
- New vs Old Arch: `android/src/newarch/.../ReactNativeGetLocationModule.java` vs `android/src/oldarch/...`. Selected via Gradle property `newArchEnabled` (see `android/build.gradle`).
- iOS native flow: `LocationModuleImpl.m` (CLLocationManager, manual NSTimer timeout, progressive authorization). Old arch bridge `LocationModule.m`; new arch bridge `RNGetLocationTurbo.mm` behind `RCT_NEW_ARCH_ENABLED`.

3. Call Flow (happy path)
JS merge defaults -> (Android) request permission -> invoke native `getCurrentPosition` -> native starts updates + timeout -> first valid fix resolves -> JS returns typed `Location`.

4. Error Codes (must stay verbatim across platforms)
`CANCELLED`: "Location cancelled by user or by another request"
`UNAVAILABLE`: "Location service is disabled or unavailable"
`TIMEOUT`: "Location timed out"
`UNAUTHORIZED`: "Location permission denied by the user"

5. Adding a Location field (backwards compatible only)
Update (a) `src/specs/NativeRNGetLocation.ts` (optional doc'd property) (b) Android `onLocationChanged` map (guard availability) (c) iOS dictionary in `didUpdateLocations` (d) README Location table (e) Keep existing fields unchanged.

6. Build & Publish
TypeScript: `yarn build` (outputs `dist/`). Publish ONLY via `node scripts/publish.js` (temporarily rewrites `package.json` main/types then restores). Do not manually point `main` to `dist` in source.

7. New Architecture Switches
Android: enable with `-PnewArchEnabled=true` or `ORG_GRADLE_PROJECT_newArchEnabled=true`. iOS: set env `RCT_NEW_ARCH_ENABLED=1` before `pod install` (activates TurboModule + Podspec conditional deps).

8. Permissions Handling
Android: always map denial to `UNAUTHORIZED` with canonical message (fine vs coarse irrelevant to user). iOS: only check authorization in `locationManagerDidChangeAuthorization`; avoid duplicate checks.

9. Timeout & Concurrency
Timeout always rejects with `TIMEOUT` + fixed message. A new request before completion must cancel the previous with `CANCELLED` + fixed message.

10. Do / Don't
Do keep license header in new native/TS files. Do keep messages identical across layers. Don't add continuous watch APIs. Don't add new public options without coordinated docs + type update. Don't introduce 3rd‑party location dependencies (Play Services, etc.).

11. Key Files
API: `src/index.ts` | Types: `src/specs/NativeRNGetLocation.ts` | Errors: `src/LocationError.ts` | Android core: `.../util/GetLocation.java` | iOS core: `LocationModuleImpl.m`.

12. Quick Usage Example
```ts
import GetLocation, {isLocationError} from 'react-native-get-location';
try { 
  const loc = await GetLocation.getCurrentPosition({enableHighAccuracy:true, timeout:15000}); 
  } catch(e){ 
    if (isLocationError(e)) {
      console.warn(e.code, e.message); 
    }
  }
```

If unsure about cross-platform parity or wording of an error message, open a PR comment before changing.
