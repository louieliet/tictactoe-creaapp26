//
//  ContentView.swift
//  tictactoe
//
//  Created by Emiliano Montes Gómez on 13/04/26.
//

// ─────────────────────────────────────────────────────────────────────────────
// SESIÓN 2: Estado reactivo en SwiftUI + Turnos X/O
// ─────────────────────────────────────────────────────────────────────────────
// En esta sesión aprendemos:
//   · @State: cómo un valor que cambia actualiza la UI automáticamente
//   · Propiedades computadas: valores que se calculan a partir de otros
//   · Closures como parámetros: pasar funciones como si fueran datos
//   · guard: salida anticipada para manejar condiciones inválidas
//   · private: control de acceso, quién puede ver qué dentro de un struct
//   · Modifiers de jerarquía visual: background, clipShape, padding avanzado
// ─────────────────────────────────────────────────────────────────────────────

// Mismo import de siempre: necesitamos SwiftUI para todo lo visual y los
// property wrappers como @State que veremos en esta sesión.
import SwiftUI


// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTE GLOBAL
// ─────────────────────────────────────────────────────────────────────────────

// El título del juego nunca cambia: sigue siendo una constante global (let).
// Contraste con @State que veremos abajo: @State es para datos QUE SÍ cambian.
let tituloJuego: String = "Tic Tac Toe"


// ─────────────────────────────────────────────────────────────────────────────
// VISTA PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

struct ContentView: View {

    // ─── ESTADO DEL JUEGO ────────────────────────────────────────────────────
    //
    // @State es un PROPERTY WRAPPER: una capa especial que envuelve una variable
    // y le da superpoderes. Cuando su valor cambia, SwiftUI vuelve a dibujar
    // la vista AUTOMÁTICAMENTE. Sin @State, cambiar un valor no actualizaría
    // nada visible en pantalla.
    //
    // Regla de oro: si un dato cambia Y la UI debe reflejarlo → usa @State.
    //
    // "private" significa que esta propiedad SOLO puede usarse dentro de
    // ContentView. Nadie más puede leerla ni modificarla desde afuera.
    // Buena práctica: encapsula el estado para que nadie lo modifique por error.
    //
    // Array(repeating: "", count: 9) crea un arreglo de 9 cadenas vacías.
    // Es equivalente a escribir ["","","","","","","","",""] pero más expresivo
    // y fácil de modificar si el tablero cambiara de tamaño.
    @State private var tablero: [String] = Array(repeating: "", count: 9)

    // El jugador que tiene el turno actual: empieza en "X".
    // @State porque cambia con cada jugada y la UI debe reflejarlo.
    @State private var turnoActual: String = "X"

    // ─── PROPIEDADES COMPUTADAS ───────────────────────────────────────────────
    //
    // Una PROPIEDAD COMPUTADA no almacena un valor: lo CALCULA cada vez que
    // alguien la lee, a partir de otras propiedades existentes.
    // No necesita @State porque no guarda nada, solo transforma lo que ya existe.
    //
    // "var colorTurno: Color" calcula el color del jugador actual.
    // Si turnoActual es "X" → azul; si es "O" → rojo.
    // Cada vez que turnoActual cambie (por @State), colorTurno devolverá
    // el color correcto sin que tengamos que hacer nada extra.
    private var colorTurno: Color {
        turnoActual == "X" ? .blue : .red
    }

    // ─── INTERFAZ ─────────────────────────────────────────────────────────────

    var body: some View {

        VStack(spacing: 24) {

            // MARK: Título
            // Igual que en sesión 1: constante, no necesita @State.
            Text(tituloJuego)
                .font(.largeTitle)
                .fontWeight(.bold)

            // MARK: Indicador de turno (ahora dinámico)
            // En sesión 1 este texto era fijo: "Turno de: X".
            // Ahora usamos interpolación de cadenas "\(turnoActual)" para que
            // el texto se actualice automáticamente cuando @State cambie.
            // colorTurno también cambia automáticamente gracias a la propiedad computada.
            Text("Turno de: \(turnoActual)")
                .font(.title3)
                .fontWeight(.semibold)
                // Usamos colorTurno (propiedad computada) en lugar de un color fijo.
                .foregroundStyle(colorTurno)
                // ".padding(.horizontal, 20)" agrega 20 puntos de espacio solo a los lados.
                // ".padding(.vertical, 8)" agrega 8 puntos arriba y abajo.
                // Juntos crean el efecto de "pastilla" alrededor del texto.
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                // ".background" aplica un fondo a la vista.
                // Usamos el mismo colorTurno con baja opacidad para crear consistencia visual.
                .background(colorTurno.opacity(0.12))
                // ".clipShape(Capsule())" recorta la vista en forma de cápsula (rectángulo
                // con extremos completamente redondeados). Crea el efecto de "badge" o "chip".
                .clipShape(Capsule())

            // MARK: Tablero 3x3
            // Las columnas no cambian: siguen siendo 3 columnas flexibles.
            let columnas = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columnas, spacing: 8) {

                ForEach(0..<9, id: \.self) { indice in

                    // NOVEDAD DE SESIÓN 2: ahora pasamos "alTocar" a cada celda.
                    // "alTocar" es un CLOSURE: una función que le pasamos como parámetro.
                    // "{ jugarCelda(en: indice) }" es la función que se ejecutará
                    // cuando el usuario toque esa celda específica.
                    // Así CeldaView no necesita saber nada del juego:
                    // solo avisa "me tocaron" y ContentView decide qué hacer.
                    CeldaView(
                        contenido: tablero[indice],
                        indice: indice,
                        alTocar: { jugarCelda(en: indice) }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    // ─── LÓGICA DEL JUEGO ─────────────────────────────────────────────────────

    // "func" define una FUNCIÓN: un bloque de código con nombre que podemos
    // reutilizar. Esta función contiene la lógica de "jugar una celda".
    // Separar lógica de UI es fundamental: el body describe CÓMO SE VE,
    // las funciones describen QUÉ HACE el juego.
    //
    // "private" porque nadie fuera de ContentView debe poder llamar esta función.
    // "en indice: Int" es el parámetro: recibe el índice de la celda tocada.
    // La etiqueta "en" hace que la llamada se lea como lenguaje natural:
    // jugarCelda(en: 4) → "jugar celda en posición 4"
    private func jugarCelda(en indice: Int) {

        // "guard" es la herramienta de SALIDA ANTICIPADA de Swift.
        // Evalúa una condición y, si NO se cumple, ejecuta el bloque "else { return }".
        // "return" detiene la función inmediatamente, sin ejecutar el resto.
        //
        // guard tablero[indice].isEmpty → "la celda debe estar vacía para jugar"
        // Si la celda YA tiene "X" u "O", no cumple la condición → salimos.
        // Esto bloquea que un jugador sobreescriba una celda ya jugada.
        //
        // Comparación: podríamos escribir "if !tablero[indice].isEmpty { return }"
        // pero guard hace la INTENCIÓN más clara: estamos GARANTIZANDO una condición.
        guard tablero[indice].isEmpty else { return }

        // Si llegamos aquí, la celda estaba vacía y es válida jugarla.
        // Modificamos el arreglo @State: SwiftUI detecta el cambio y redibuja la UI.
        // tablero[indice] = turnoActual → ponemos "X" o "O" en esa posición.
        tablero[indice] = turnoActual

        // Cambiamos de turno usando el operador ternario:
        // Si era "X" → pasa a "O"; si era "O" → pasa a "X".
        // Al modificar turnoActual (@State), el indicador de turno se actualiza solo.
        turnoActual = turnoActual == "X" ? "O" : "X"
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// VISTA DE CELDA INDIVIDUAL
// ─────────────────────────────────────────────────────────────────────────────

// CeldaView sigue siendo un struct independiente (responsabilidad única).
// CAMBIO DE SESIÓN 2: ahora recibe "alTocar", un closure que ejecuta
// cuando el usuario toca la celda. Así la lógica queda en ContentView
// y CeldaView solo sabe mostrarse y avisar cuando la tocan.
struct CeldaView: View {

    let contenido: String  // Qué tiene la celda: "", "X" o "O"
    let indice: Int        // Posición en el tablero (0-8)

    // "alTocar: () -> Void" es un CLOSURE como propiedad.
    // "()" → la función no recibe ningún parámetro.
    // "Void" → la función no devuelve ningún valor (solo ejecuta algo).
    // Leer como: "alTocar es una función que no recibe nada y no devuelve nada".
    // Cuando ContentView crea esta celda, le pasa qué hacer al tocarla.
    let alTocar: () -> Void

    // ─── PROPIEDAD COMPUTADA ──────────────────────────────────────────────────
    //
    // El color de fondo de la celda cambia según su contenido:
    // · Vacía → azul tenue (neutro, invita a jugar)
    // · "X"   → azul (identidad visual del jugador X)
    // · "O"   → rojo (identidad visual del jugador O)
    //
    // Separar este cálculo en una propiedad computada mantiene el body limpio.
    // Si mañana queremos cambiar los colores, solo tocamos este lugar.
    private var colorCelda: Color {
        if contenido == "X" { return .blue }
        if contenido == "O" { return .red }
        return .blue  // vacía: tono neutro azul
    }

    var body: some View {

        ZStack {

            // Fondo de la celda: usa colorCelda (propiedad computada).
            // El color cambia automáticamente cuando "contenido" cambia,
            // porque colorCelda se recalcula cada vez que se lee.
            RoundedRectangle(cornerRadius: 12)
                .fill(colorCelda.opacity(0.12))
                .aspectRatio(1, contentMode: .fit)

            if contenido.isEmpty {
                // Celda vacía: sutil indicador de posición.
                // En producción podríamos quitarlo; aquí lo dejamos para el taller.
                Text("\(indice)")
                    .font(.caption)
                    .foregroundStyle(.gray.opacity(0.35))
            } else {
                // Celda jugada: muestra "X" o "O" en grande con su color.
                Text(contenido)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(contenido == "X" ? .blue : .red)
            }
        }
        // CAMBIO DE SESIÓN 2: en lugar de print(), llamamos al closure alTocar().
        // La sintaxis "alTocar()" ejecuta la función que nos pasaron como parámetro.
        // ContentView decidió qué hace esa función: registrar la jugada.
        // CeldaView no sabe nada del juego; solo dispara el evento. ← responsabilidad única
        .onTapGesture {
            alTocar()
        }
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

// Igual que antes: solo para ver la vista en el Canvas de Xcode durante desarrollo.
#Preview {
    ContentView()
}
