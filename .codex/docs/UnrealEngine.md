# Unreal Engine Guidance

## Use This Document When

- Open and follow this document whenever the task involves Unreal Engine source code, Unreal build behavior, Unreal project structure, Unreal-specific debugging helpers, or Unreal coding conventions.
- Rules in **General Rules** are mandatory unless a more specific user or workspace instruction explicitly overrides them.
- Items in **Preferences** are the default choice. Follow them unless an established local pattern or concrete technical requirement provides a reason not to.

## General Rules

### File Writing

- When creating new files, always use Unix line endings (`LF`), not `CRLF`.

### C++ Style

- In a `.cpp` file with a matching `.h` file, include that matching header first, regardless of its path prefix. Separate it from all other includes with exactly one blank line. Apply the remaining include-order rules only after this matching-header block.
- Include order rule: headers without a subdirectory prefix come first, then headers with subdirectory prefixes; within each group, sort in ascending, case-insensitive lexicographical order. Keep these groups contiguous without an extra blank line between them.
- Place all angle-bracket includes (`#include <...>`) after all quoted includes (`#include "..."`), including any `.generated.h` include. Separate the angle-bracket include block from the quoted includes with exactly one blank line.
- If a header includes a generated header, keep its `.generated.h` include last among the quoted includes. Exclude the generated header from the normal include-order groups.
- Do not use anonymous namespaces. For free functions, variables, constants, and registration objects that require internal linkage in a `.cpp` file, declare them `static`.
- Indent all content inside a namespace by one tab relative to the namespace declaration. This includes classes, structs, static helpers, free functions, and out-of-line member-function definitions.
- In every Unreal reflection macro, including `UCLASS`, `UENUM`, `UFUNCTION`, `UINTERFACE`, `UPARAM`, `UPROPERTY`, `USTRUCT`, and similar macros, sort specifiers by specifier name in ascending, case-insensitive lexicographical order. Ignore assigned values when comparing names. Spell the metadata specifier as `Meta` with an uppercase `M`. If present, place `Category` second to last and `Meta` last. Sort entries inside `Meta = (...)` by the same lexicographical rule. `ClassGroup` and other specifiers follow the normal alphabetical order; they are not treated as `Category`.

  ```cpp
  #include "Components/RayTracingMeshComponent.h"

  #include "FoliageType.h"
  #include "Async/Fundamental/Scheduler.h"
  #include "Engine/CollisionProfile.h"
  #include "Engine/RayTracingMeshAsset.h"

  #include <type_traits>
  ```

  ```cpp
  namespace Feature
  {
  	static bool IsSupported()
  	{
  		return true;
  	}

  	void FProcessor::Run()
  	{
  		// ...
  	}
  }
  ```

  ```cpp
  UCLASS(Abstract, BlueprintType, NotBlueprintable, Meta = (DisplayName = "Ray Tracing Mesh"))
  UPROPERTY(BlueprintReadOnly, EditAnywhere, Category = "Ray Tracing", Meta = (AllowPrivateAccess = "true", DisplayName = "Mesh"))
  UFUNCTION(BlueprintCallable, Category = "Ray Tracing", Meta = (DisplayName = "Set Mesh"))
  ```

### Custom Show Flags

- For custom show flags, inspect local engine patterns first. If the engine only provides process-lifetime registration and no unregister path, do not invent ad hoc unregister behavior; prefer the existing static-registration style.

### Build And Validation

- Do not build or run compile validation by default.
- Only compile when the user explicitly asks for it.
- When the build command is not documented in the local workspace instructions, stop and ask instead of inventing one.
- Workspace-local instructions may define the default compile validation target for a specific engine or project. Follow the local workspace instructions when they do.
- If a build fails because the target artifact is currently running, such as `UnrealEditor` or a packaged game executable, stop and ask whether the user wants to cancel the build or retry after they close the running process themselves. Wait for the user's response before continuing. Do not terminate the process on the user's behalf, work around the running process, or attempt to build the target independently.

## Preferences

### C++ Implementation

- For user-facing multi-line debug text that is ultimately drawn line-by-line, prefer storing and building `TArray<FString>` directly instead of composing one newline-joined `FString` and splitting it again later.
- When a mutex is needed, prefer `UE::FMutex` with `UE::TScopeLock` using CTAD style, for example `UE::TScopeLock SL(Mutex);`.
- For `UE::TScopeLock`, prefer the local variable name `SL`.
- In private `.cpp` files in these Unreal C++ workspaces, keep includes lean and rely on the module PCH when practical instead of redundantly including headers already covered there.
- Prefer explicit `TCustomShowFlag<>` instead of relying on CTAD for `TCustomShowFlag`.
- When using `UDebugDrawService` with a custom show flag, avoid redundantly calling `TCustomShowFlag::IsEnabled()` inside the draw delegate if the service callback is already gated by that show flag.
- If a debug draw path is already invoked every frame when visible, prefer driving lightweight update scheduling from `Draw` instead of keeping a parallel `Tick` path unless a separate tick is actually needed.
