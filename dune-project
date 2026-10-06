(lang dune 3.24)

; Sans ceci, dune réécrit les chemins absolus en `/workspace_root` (builds
; reproductibles) et le débogueur ne retrouve plus les sources.
(map_workspace_root false)

; Sans ceci, le module de `bac_a_sable/bac_a_sable.ml` s'appelle `Dune__exe__Bac_a_sable` dans le
; débogueur au lieu de `Bac_a_sable`.
(wrapped_executables false)
