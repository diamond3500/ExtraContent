# signals

## Usage
The core api is very minimal, consisting of three core primitives:

### `createSignal`
```luau
createSignal<T>(initial: T | () -> T, equals: equals<T>?): (getter<T>, setter<T>)
```
Creates a queryable and settable value.
* Lazy-initializable with a constructor 
* Cacheable with an optional `equals` parameter
* The getter can be provided a `scope` for automatic dependency tracking (see [createComputed](#createComputed) and [createEffect](#createEffect))
```luau
local getFirstName, setFirstName = signals.createSignal("David")
local getLastName, setLastName = signals.createSignal("Tennant")

print(getFirstName(false)) -- prints: David

setFirstName("The")
setLastName("Doctor")

print(`{getFirstName(false)} {getLastName(false)}`) -- prints: The Doctor
```

### `createComputed`
```luau
createComputed<T>(computed: (scope) -> T, equals: equals<T>?): getter<T>
```
Creates a read-only reactive dervied value.
* Lazy evaluation (computed updates when value is read)
* Can be used to define "derived" state using signals and other computeds
* The `scope` can be used to automatically and reactively track updates to dependencies
```luau
local getFullName = signals.createComputed(function(scope)
    return `{getFirstName(scope)} {getLastName(scope)}`
end)

print(getFullName(false)) -- prints: The Doctor
```

### `createEffect`
```luau
createEffect(effect: (scope, dispose) -> ()): dispose
```
Creates a reactive side effect.
* Eager evaluation
* The `scope` can be used to automatically and reactively track updates to dependencies
```luau
local dispose = signals.createEffect(function(scope)
    print(`Their real name is {getFullName(scope)}`)
end)
-- prints: Their real name is The Doctor

setFirstName("David")
setLastName("Tennant")
task.wait()
-- prints: Their real name is David Tennant

dispose()
```

### Batching

This library includes a "deferred mode" that can be enabled via a flag:
```luau
local deferredModeEnabled = _G.__SIGNALS_DEFERRED_MODE_ENABLED__ or _G.__DEV__
```
This flag enables automatic batching and processing of state updates.
