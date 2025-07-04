.macro OnceDuringNMI label
  AddHook nmi_once_hooks, label
.endmacro