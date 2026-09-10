(lang dune 3.24)

; Sans ceci, dune réécrit les chemins absolus en `/workspace_root` (builds
; reproductibles) et le débogueur ne retrouve plus les sources.
(map_workspace_root false)

; Sans ceci, le module de `tp1/tp1.ml` s'appelle `Dune__exe__Tp1` dans le
; débogueur au lieu de `Tp1`.
(wrapped_executables false)
