(lang dune 3.24)

; Sans ceci, dune réécrit les chemins absolus en `/workspace_root` (builds
; reproductibles) et le débogueur ne retrouve plus les sources.
(map_workspace_root false)
