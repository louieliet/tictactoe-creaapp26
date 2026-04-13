//
//  ContentView.swift
//  tictactoe
//
//  Created by Emiliano Montes Gómez on 13/04/26.
//

// ─────────────────────────────────────────────────────────────────────────────
// SESIÓN 3: POO básica + Motor de reglas del juego
// ─────────────────────────────────────────────────────────────────────────────
// En esta sesión aprendemos:
//   · Separación de responsabilidades: GameLogic.swift vs ContentView.swift
//   · enum con valores asociados: estado del juego como tipo propio
//   · switch exhaustivo: cubrir todos los casos de un enum
//   · if let (optional binding): manejar valores que pueden no existir
//   · Consumir lógica externa desde la vista (GameLogic.verificarGanador)
//   · Bloquear la UI cuando el juego termina
// ─────────────────────────────────────────────────────────────────────────────

// La lógica del juego ahora vive en GameLogic.swift.
// ContentView solo se ocupa de la interfaz: consume GameLogic como herramienta.
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

    // NOVEDAD SESIÓN 3: estado del juego usando el enum de GameLogic.swift.
    // @State porque cambia cuando alguien gana o hay empate.
    // Valor inicial: .jugando (la partida empieza en curso).
    // El punto antes del caso (.jugando) es la sintaxis de Swift para enums:
    // no necesitamos escribir EstadoJuego.jugando porque Swift infiere el tipo.
    @State private var estadoJuego: EstadoJuego = .jugando

    // ─── PROPIEDADES COMPUTADAS ───────────────────────────────────────────────

    // "mensajeEstado" calcula el texto del badge según el estado actual del juego.
    // Usa "switch": la estructura de control que cubre TODOS los casos de un enum.
    // Swift obliga que el switch sea EXHAUSTIVO: si no cubres un caso, error de compilación.
    // Eso garantiza que nunca olvidemos manejar un estado posible del juego.
    //
    // "case .ganador(let jugador)" extrae el valor asociado del enum:
    // "jugador" recibe el String que guardamos cuando llamamos .ganador(jugador: "X").
    private var mensajeEstado: String {
        switch estadoJuego {
        case .jugando:
            return "Turno de: \(turnoActual)"
        case .ganador(let jugador):
            return "¡\(jugador) ganó!"
        case .empate:
            return "¡Empate!"
        }
    }

    // "colorEstado" calcula el color del badge según el estado.
    // Mismo patrón switch: un color por cada estado posible.
    // .orange para empate da señal visual neutral (ni azul de X ni rojo de O).
    private var colorEstado: Color {
        switch estadoJuego {
        case .jugando:
            return turnoActual == "X" ? .blue : .red
        case .ganador(let jugador):
            return jugador == "X" ? .blue : .red
        case .empate:
            return .orange
        }
    }

    // ─── INTERFAZ ─────────────────────────────────────────────────────────────

    var body: some View {

        VStack(spacing: 24) {

            // MARK: Título
            // Igual que en sesión 1: constante, no necesita @State.
            Text(tituloJuego)
                .font(.largeTitle)
                .fontWeight(.bold)

            // MARK: Badge de estado (turno o resultado final)
            // NOVEDAD SESIÓN 3: ya no mostramos solo el turno.
            // mensajeEstado y colorEstado (propiedades computadas con switch)
            // calculan automáticamente qué mostrar según EstadoJuego.
            // Cuando estadoJuego cambie a .ganador o .empate, este badge
            // se actualiza solo sin ningún código extra aquí.
            Text(mensajeEstado)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(colorEstado)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(colorEstado.opacity(0.12))
                .clipShape(Capsule())
                // ".animation" aplica una transición suave cuando el valor cambia.
                // ".default" usa la animación estándar de SwiftUI.
                // "value: mensajeEstado" le dice a SwiftUI QUÉ cambio debe animar.
                .animation(.default, value: mensajeEstado)

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

    private func jugarCelda(en indice: Int) {

        // NOVEDAD SESIÓN 3: primer guard bloquea jugadas cuando la partida terminó.
        // estadoJuego.estaJugando es la propiedad computada del enum.
        // Si el juego ya terminó (.ganador o .empate), salimos inmediatamente.
        // Esto evita que los jugadores sigan tocando celdas después del resultado.
        guard estadoJuego.estaJugando else { return }

        // Segundo guard: la celda debe estar vacía (igual que sesión 2).
        guard tablero[indice].isEmpty else { return }

        // Registramos la jugada en el tablero.
        tablero[indice] = turnoActual

        // NOVEDAD SESIÓN 3: verificamos si alguien ganó tras esta jugada.
        //
        // "if let ganador = GameLogic.verificarGanador(en: tablero)" es OPTIONAL BINDING.
        // verificarGanador devuelve String? (un optional: puede ser "X", "O", o nil).
        // "if let" desenvuelve el optional: si hay valor, lo asigna a "ganador" y entra.
        // Si devuelve nil (no hay ganador), omite ese bloque y evalúa el siguiente.
        //
        // Usamos GameLogic (el struct del otro archivo) como herramienta:
        // ContentView no sabe CÓMO se detecta el ganador, solo llama a quien sí sabe.
        if let ganador = GameLogic.verificarGanador(en: tablero) {

            // Asignamos el nuevo estado al @State: SwiftUI redibuja el badge.
            // Usamos el valor asociado: .ganador(jugador: ganador) empaqueta
            // el símbolo del ganador junto con el caso del enum.
            estadoJuego = .ganador(jugador: ganador)

        } else if GameLogic.verificarEmpate(en: tablero) {

            // Si no hay ganador PERO el tablero está lleno → empate.
            // El orden importa: siempre verificar ganador ANTES de empate.
            estadoJuego = .empate

        } else {

            // Si no hay ganador ni empate, el juego continúa: cambiamos turno.
            turnoActual = turnoActual == "X" ? "O" : "X"
        }
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
