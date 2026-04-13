# Planeación del Taller Swift: Tic Tac Toe (Prepa)

## Datos generales

- **Duración total:** 4 sesiones
- **Duración por sesión:** 2 horas
- **Proyecto final:** App de Tic Tac Toe en SwiftUI
- **Enfoque:** Fundamentos de Swift + estado en UI + POO básica + producto funcional

## Objetivo general

Al finalizar el taller, el alumno será capaz de construir una app funcional de Tic Tac Toe aplicando:

- Variables, constantes y tipos en Swift
- Condicionales, arreglos y funciones
- Manejo de estado en SwiftUI
- Conceptos básicos de POO para organizar lógica y vistas

---

## Sesión 1 (2h) — Fundamentos Swift + tablero base (25%)

### Objetivo de aprendizaje

Comprender la sintaxis base de Swift y construir la primera versión visual del tablero 3x3.

### Bloques sugeridos (tiempo)

- **20 min:** Introducción a Swift (variables, constantes, tipos)
- **25 min:** Mini ejercicios guiados (Int, String, Bool, Array)
- **55 min:** Construcción del tablero visual en SwiftUI
- **15 min:** Debug en grupo y preguntas
- **5 min:** Cierre y tarea breve

### Contenidos clave

- `let` vs `var`
- Tipos básicos: `String`, `Int`, `Bool`
- Arreglos e índices
- `if` básico
- Estructura de una vista en SwiftUI

### Avance del juego (1/4)

- Crear pantalla principal
- Dibujar tablero 3x3
- Mostrar celdas vacías con estilo básico
- Dejar preparada la interacción de celdas

### Checklist sesión 1

- [ ] El proyecto corre sin errores
- [ ] El alumno distingue `let` y `var`
- [ ] El alumno declara y usa tipos básicos correctamente
- [ ] El tablero 3x3 se muestra correctamente
- [ ] Se entiende cómo representar estado base del tablero

---

## Sesión 2 (2h) — Estado en SwiftUI + turnos (50%)

### Objetivo de aprendizaje

Entender cómo el estado actualiza la interfaz e implementar turnos X/O con interacción real.

### Bloques sugeridos (tiempo)

- **20 min:** Concepto de estado reactivo en SwiftUI
- **25 min:** Mini práctica de UI reactiva (cambio de texto/estilo)
- **55 min:** Implementación de jugadas por turno
- **15 min:** Debug en grupo y preguntas
- **5 min:** Cierre y tarea breve

### Contenidos clave

- Estado local para vistas
- Flujo de datos en vistas
- Re-render automático de interfaz
- `modifiers` para jerarquía visual y legibilidad

### Avance del juego (2/4)

- Tap en celda para jugar
- Alternancia de turno entre X y O
- Bloqueo de celdas ya ocupadas
- Indicador visual del turno actual

### Checklist sesión 2

- [ ] Cada tap registra una jugada válida
- [ ] El turno cambia correctamente entre jugadores
- [ ] No se puede sobreescribir una celda ocupada
- [ ] El tablero refleja cambios en tiempo real
- [ ] La UI tiene estructura visual clara (espaciado/colores/texto)

---

## Sesión 3 (2h) — POO básica + reglas del juego (75%)

### Objetivo de aprendizaje

Aplicar POO básica para separar responsabilidades e implementar reglas completas del juego.

### Bloques sugeridos (tiempo)

- **20 min:** POO aplicada al proyecto (modelo vs vista vs lógica)
- **25 min:** Mini práctica de funciones de validación
- **55 min:** Detección de ganador y empate
- **15 min:** Debug en grupo y preguntas
- **5 min:** Cierre y tarea breve

### Contenidos clave

- Responsabilidad única por componente
- Organización de funciones por propósito
- Validación de condiciones en tablero

### Avance del juego (3/4)

- Detectar líneas ganadoras (filas, columnas, diagonales)
- Detectar empate
- Mostrar estado de partida finalizada
- Bloquear jugadas cuando termina la partida

### Checklist sesión 3

- [ ] El juego detecta ganador correctamente
- [ ] El juego detecta empate correctamente
- [ ] El estado final se muestra al usuario
- [ ] No permite jugadas después de finalizar
- [ ] La lógica está separada de la presentación visual

---

## Sesión 4 (2h) — Pulido, reinicio y demo final (100%)

### Objetivo de aprendizaje

Cerrar una app funcional y estable, reforzando calidad de código y presentación final.

### Bloques sugeridos (tiempo)

- **20 min:** Buenas prácticas de legibilidad y organización
- **25 min:** Revisión guiada de calidad y casos borde
- **55 min:** Implementación final y pulido visual
- **15 min:** Demo por equipos/alumnos
- **5 min:** Cierre del taller

### Contenidos clave

- Limpieza de código (nombres y funciones)
- Debugging guiado
- Pruebas manuales con checklist
- Entrega funcional de producto

### Avance del juego (4/4)

- Botón de reiniciar partida
- Indicadores finales claros (ganador/empate)
- Pulido de interfaz
- Demo funcional completa

### Checklist sesión 4

- [ ] El botón de reinicio deja el juego en estado inicial
- [ ] Se muestran mensajes claros de resultado
- [ ] El flujo completo de partida funciona sin errores
- [ ] La interfaz es clara y presentable
- [ ] El alumno puede explicar su solución

---

## Checklist global de proyecto final

- [ ] Tablero 3x3 interactivo
- [ ] Turnos X/O correctos
- [ ] Bloqueo de celdas ocupadas
- [ ] Detección de ganador
- [ ] Detección de empate
- [ ] Reinicio de partida
- [ ] UI clara, ordenada y legible

## Recomendación didáctica para cada sesión

- Explica concepto → demuestra → practica → integra al proyecto
- Mantén ciclos cortos para sostener atención
- Prioriza que todos logren un resultado visible cada clase
- Usa errores comunes como oportunidad de aprendizaje en vivo
