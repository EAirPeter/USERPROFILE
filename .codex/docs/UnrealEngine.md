# Unreal Engine Guidance

## Use This Document When

- Open and follow this document whenever the task involves Unreal Engine source code, Unreal build behavior, Unreal project structure, Unreal-specific debugging helpers, or Unreal coding conventions.
- Rules in **General Rules** are mandatory unless a more specific user or workspace instruction explicitly overrides them.
- Items in **Preferences** are the default choice. Follow them unless an established local pattern or concrete technical requirement provides a reason not to.
- Consult nearby maintained code and representative changes for style choices the guide leaves open. Review Rider and Clang-Tidy suggestions against the applicable guidance and local style before applying them.

## General Rules

### File Writing

- When creating new files, always use Unix line endings (`LF`), not `CRLF`.

### C++ Style

#### Layout And Linkage

- Indent C++ blocks with one tab per level, including namespace bodies. Use Allman braces for multiline blocks.
- Keep empty blocks as `{}`. Put an empty function or type body on the same line as its signature or header. After a constructor initializer list, put `{}` on its own line at the constructor's indentation.
- For conditional compilation, indent the C++ as usual. Place the opening directive (`#if`, `#ifdef`, or `#ifndef`) one tab to the left of the surrounding C++ indentation, stopping at column one. Align the corresponding `#elif`, `#else`, and `#endif` with it.
- Use tabs to align names and default initializers within related groups of member declarations. Put each constructor initializer on its own line, with a leading colon on the first and leading commas on the rest.
- Do not use anonymous namespaces. For free functions, variables, constants, and registration objects that require internal linkage in a `.cpp` file, declare them `static`.

```cpp
namespace Feature
{
	static bool IsSupported()
	{
	#if WITH_EDITOR
		return true;
	#else
		return false;
	#endif
	}
}
```

```cpp
void OnStreamComplete() {}

class FStreamingTag {};

struct FLODRange
{
	FLODRange() {}

	FLODRange(int32 InFirstLOD, int32 InLastLOD)
		: FirstLOD(InFirstLOD)
		, LastLOD(InLastLOD)
	{}

	int32	FirstLOD	= 0;
	int32	LastLOD		= 0;
};
```

#### Naming

- Prefix non-boolean `std::atomic` variables and members with `Atomic`, and `std::atomic<bool>` variables and members with `bAtomic`.
- Name byte-count variables, parameters, and members with `Size` rather than `Bytes` (for example, `BufferSize`, `PayloadSize`, and `StreamableDataSize`, not `BufferBytes` or `PayloadBytes`).

```cpp
uint32						PayloadSize		= 0;
std::atomic<uint32>			AtomicState{0};
std::atomic<bool>			bAtomicComplete{false};
```

#### Includes

- In a `.cpp` file with a matching `.h` file, include that matching header first, regardless of its path prefix. Separate it from all other includes with exactly one blank line. Apply the remaining include-order rules only after this matching-header block.
- Include order rule: headers without a subdirectory prefix come first, then headers with subdirectory prefixes; within each group, sort in ascending, case-insensitive lexicographical order. Keep these groups contiguous without an extra blank line between them.
- Place angle-bracket includes (`#include <...>`) after the regular quoted includes (`#include "..."`). Separate the two groups with exactly one blank line.
- If a header has a `.generated.h` include, place it after all other includes, including angle-bracket includes. Exclude it from the normal include-order groups.

```cpp
#include "Components/RayTracingMeshComponent.h"

#include "FoliageType.h"
#include "Async/Fundamental/Scheduler.h"
#include "Engine/CollisionProfile.h"
#include "Engine/RayTracingMeshAsset.h"

#include <type_traits>
```

#### Reflection Macros

- In every Unreal reflection macro, including `UCLASS`, `UENUM`, `UFUNCTION`, `UINTERFACE`, `UPARAM`, `UPROPERTY`, `USTRUCT`, and similar macros, sort specifiers by specifier name in ascending, case-insensitive lexicographical order. Ignore assigned values when comparing names. Spell the metadata specifier as `Meta` with an uppercase `M`. If present, place `Category` second to last and `Meta` last. Sort entries inside `Meta = (...)` by the same lexicographical rule. `ClassGroup` and other specifiers follow the normal alphabetical order; they are not treated as `Category`.

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

- Prefer explicit types for ordinary local declarations and range-for elements. Use `auto` for lambdas and for iterators whose explicit types would obscure the code.
- Do not spell out the default `, ESPMode::ThreadSafe` argument on Unreal smart-pointer types or helpers (`TSharedPtr<T>`, `TSharedRef<T>`, `TWeakPtr<T>`, `TSharedFromThis<T>`, `MakeShared<T>()`).
- Prefer references (`T&` or `const T&`) over raw pointers when a value is guaranteed non-null and is never rebound, including reference members initialized at construction and non-null parameters (except where UHT reflection requires `TObjectPtr<T>` or `UObject*`).
- When a mutex is needed, prefer `UE::FMutex` with `UE::TScopeLock`. Use class template argument deduction for the lock and name it `SL`, as in `UE::TScopeLock SL(Mutex);`.
- Spell out `TCustomShowFlag<>` with its template argument list.
- In private `.cpp` files in these Unreal C++ workspaces, keep includes lean and rely on the module PCH when practical instead of redundantly including headers already covered there.
- For user-facing multi-line debug text that is ultimately drawn line-by-line, prefer storing and building `TArray<FString>` directly instead of composing one newline-joined `FString` and splitting it again later.
- When using `UDebugDrawService` with a custom show flag, avoid redundantly calling `TCustomShowFlag::IsEnabled()` inside the draw delegate if the service callback is already gated by that show flag.
- If a debug draw path is already invoked every frame when visible, prefer driving lightweight update scheduling from `Draw` instead of keeping a parallel `Tick` path unless a separate tick is actually needed.
