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
// FEATURE: sofia-mejor-de-3
// ─────────────────────────────────────────────────────────────────────────────
// Agregamos el concepto de SERIE al mejor de 3 rondas.
// ─────────────────────────────────────────────────────────────────────────────
// FEATURE: renata-anuncio-ganador
// ─────────────────────────────────────────────────────────────────────────────
// Mostramos un alert al terminar cada ronda y al terminar la serie.
// ─────────────────────────────────────────────────────────────────────────────
// FEATURE: emilio-panel-estadisticas
// ─────────────────────────────────────────────────────────────────────────────
// Acumulador global de métricas y panel togglable bajo el tablero.
// Conceptos nuevos:
//   · Variables de sesión vs variables de serie: diferencia de alcance
//   · computed property: "private var panelView: some View" como subvista
//   · .toggle(): invierte un Bool con una sola llamada
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

    // ─── FEATURE: ESTADO DE SERIE ────────────────────────────────────────────
    //
    // Separamos dos niveles de estado:
    //   · Estado de RONDA: tablero, turnoActual, estadoJuego  (ya existían)
    //   · Estado de SERIE: victorias por jugador, ganador de serie (nuevo)
    //
    // Esta separación es la misma idea de responsabilidad única que aprendimos
    // con GameLogic.swift: cada variable describe exactamente un concepto.

    // Contadores de victorias dentro de la serie actual.
    // Int porque son números enteros positivos que incrementamos al ganar.
    @State private var victoriasX: Int = 0
    @State private var victoriasO: Int = 0

    // Ganador de la serie completa. Usamos String? (Optional) porque:
    //   · Mientras la serie está en curso, NO hay ganador → nil
    //   · Cuando alguien gana 2 rondas, guardamos "X" u "O"
    // String? significa: "puede ser un String, o puede ser nil (nada)".
    @State private var ganadorSerie: String? = nil

    // ─── FEATURE: ESTADO DEL ANUNCIO ─────────────────────────────────────────
    //
    // "mostrarAnuncio" controla si el alert está visible.
    // SwiftUI observa este @State: en cuanto cambia a true, presenta el alert.
    // Cuando el usuario toca un botón del alert, SwiftUI lo vuelve a false solo.
    @State private var mostrarAnuncio: Bool = false

    // Contenido del alert: lo llenamos justo antes de mostrarlo.
    // Separar título y mensaje permite mensajes ricos sin lógica en el body.
    @State private var tituloAnuncio: String = ""
    @State private var mensajeAnuncio: String = ""

    // Flag que distingue si el alert actual corresponde al cierre de la serie.
    // Lo usamos para mostrar el botón correcto: "Nueva Ronda" vs "Nueva Serie".
    @State private var anuncioDeSerie: Bool = false

    // ─── FEATURE: ESTADÍSTICAS GLOBALES ───────────────────────────────────────
    //
    // Diferencia clave de alcance:
    //   · victoriasX / victoriasO → son de la SERIE actual (se resetean)
    //   · totalVictoriasX / totalVictoriasO → son de la SESIÓN (nunca se resetean)
    // El mismo concepto que en videojuegos: "victorias en esta partida" vs "total histórico".
    @State private var totalPartidas: Int = 0
    @State private var totalVictoriasX: Int = 0
    @State private var totalVictoriasO: Int = 0
    @State private var totalEmpates: Int = 0

    // Controla si el panel está desplegado o colapsado.
    // .toggle() es el método de Bool que lo invierte: true → false, false → true.
    @State private var mostrarEstadisticas: Bool = false

    // ─── PROPIEDADES COMPUTADAS ───────────────────────────────────────────────

    // "mensajeEstado" calcula el texto del badge según el estado actual del juego.
    // Usa "switch": la estructura de control que cubre TODOS los casos de un enum.
    // Swift obliga que el switch sea EXHAUSTIVO: si no cubres un caso, error de compilación.
    // Eso garantiza que nunca olvidemos manejar un estado posible del juego.
    //
    // "case .ganador(let jugador)" extrae el valor asociado del enum:
    // "jugador" recibe el String que guardamos cuando llamamos .ganador(jugador: "X").
    private var mensajeEstado: String {
        // NOVEDAD: si ya hay ganador de serie, ese mensaje tiene prioridad.
        // "if let ganador = ganadorSerie" desenvuelve el Optional:
        // si ganadorSerie NO es nil, entra al bloque con el valor en "ganador".
        if let ganador = ganadorSerie {
            return "🏆 \(ganador) ganó la serie"
        }

        switch estadoJuego {
        case .jugando:
            return "Turno de: \(turnoActual)"
        case .ganador(let jugador):
            return "¡\(jugador) ganó la ronda!"
        case .empate:
            return "¡Empate en esta ronda!"
        }
    }

    // "colorEstado" calcula el color del badge según el estado.
    // Mismo patrón switch: un color por cada estado posible.
    // .orange para empate da señal visual neutral (ni azul de X ni rojo de O).
    private var colorEstado: Color {
        // Si hay ganador de serie, el color refleja al campeón.
        if let ganador = ganadorSerie {
            return ganador == "X" ? .blue : .red
        }

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

            // MARK: Marcador de serie
            // NOVEDAD: mostramos victorias acumuladas de la serie.
            // HStack = Horizontal Stack: coloca vistas en fila.
            // Los colores .blue y .red identifican visualmente a cada jugador.
            HStack(spacing: 24) {
                VStack {
                    Text("\(victoriasX)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.blue)
                    Text("X")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Mejor de 3")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack {
                    Text("\(victoriasO)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.red)
                    Text("O")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
            .background(.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))

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

            // MARK: Panel de estadísticas (togglable)
            // Un Button que no hace ninguna acción de juego: solo cambia UI.
            // .toggle() invierte mostrarEstadisticas: si era false pasa a true y viceversa.
            Button(mostrarEstadisticas ? "Ocultar estadísticas" : "Ver estadísticas 📊") {
                mostrarEstadisticas.toggle()
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // "if mostrarEstadisticas" muestra el panel solo cuando el toggle está activado.
            // Es el patrón más simple de visibilidad condicional en SwiftUI.
            if mostrarEstadisticas {
                // Llamamos a la propiedad computada que devuelve la subvista.
                // Separarla del body mantiene el body legible.
                panelEstadisticasView
            }

            // MARK: Botones contextuales de serie
            // NOVEDAD: mostramos botones distintos según el estado de la serie.
            //
            // Si la serie terminó → "Nueva Serie" (reinicia TODO)
            // Si la ronda terminó sin cerrar serie → "Nueva Ronda" (solo limpia tablero)
            // Si se está jugando → no mostramos ningún botón
            //
            // Usamos .opacity() en lugar de if/else para animar suavemente.
            // opacity 0 = invisible pero sigue en layout; if/else destruye la vista.
            if ganadorSerie != nil {
                // La serie tiene ganador: única acción disponible es reiniciar todo.
                Button("Nueva Serie") {
                    reiniciarSerie()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(colorEstado)
                .clipShape(Capsule())

            } else if !estadoJuego.estaJugando {
                // La ronda terminó pero la serie sigue: permitimos avanzar.
                Button("Nueva Ronda") {
                    reiniciarRonda()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(colorEstado)
                .clipShape(Capsule())
            }
        }
        .padding()
        // FEATURE: alert de resultado.
        // ".alert" recibe: título, binding de visibilidad, botones (actions) y mensaje.
        // "$mostrarAnuncio" es un Binding<Bool>: el "$" indica que pasamos la referencia
        // mutable, no el valor. SwiftUI la pone en false al cerrar el alert.
        .alert(tituloAnuncio, isPresented: $mostrarAnuncio) {
            if anuncioDeSerie {
                // La serie terminó: solo mostramos opción de empezar de cero.
                Button("Nueva Serie") {
                    reiniciarSerie()
                }
            } else {
                // La ronda terminó pero la serie sigue: ofrecemos continuar.
                Button("Siguiente Ronda") {
                    reiniciarRonda()
                }
            }
        } message: {
            // El bloque "message" define el cuerpo del alert.
            Text(mensajeAnuncio)
        }
    }

    // ─── LÓGICA DEL JUEGO ─────────────────────────────────────────────────────

    private func jugarCelda(en indice: Int) {

        // NOVEDAD: si la serie ya tiene ganador, bloqueamos TODAS las jugadas.
        // Es el primer guard porque tiene prioridad sobre el estado de ronda.
        guard ganadorSerie == nil else { return }

        // Igual que sesión 3: bloquear si la ronda terminó.
        guard estadoJuego.estaJugando else { return }

        // La celda debe estar vacía.
        guard tablero[indice].isEmpty else { return }

        // Registramos la jugada en el tablero.
        tablero[indice] = turnoActual

        if let ganador = GameLogic.verificarGanador(en: tablero) {

            // La ronda tiene ganador: actualizamos estado Y procesamos serie.
            estadoJuego = .ganador(jugador: ganador)

            // NOVEDAD: procesamos el resultado en el marcador de serie.
            // Esta función contiene TODO lo relacionado con la serie
            // para mantener jugarCelda limpia y fácil de leer.
            procesarResultadoRonda(ganador: ganador)

        } else if GameLogic.verificarEmpate(en: tablero) {

            // Empate de ronda: suma al contador global de empates.
            estadoJuego = .empate
            totalEmpates += 1
            totalPartidas += 1

        } else {

            // La ronda sigue: cambiamos turno.
            turnoActual = turnoActual == "X" ? "O" : "X"
        }
    }

    // Procesa el resultado de una ronda ganada y decide si la serie terminó.
    // PRINCIPIO: función pequeña con responsabilidad única.
    // jugarCelda detecta el evento; procesarResultadoRonda gestiona la serie.
    private func procesarResultadoRonda(ganador: String) {

        // Incrementamos la victoria del jugador correspondiente.
        if ganador == "X" {
            victoriasX += 1
        } else {
            victoriasO += 1
        }

        // REGLA DEL MEJOR DE 3: gana la serie quien llegue primero a 2 victorias.
        // NOVEDAD: acumulamos en el contador global de victorias.
        if ganador == "X" { totalVictoriasX += 1 } else { totalVictoriasO += 1 }
        totalPartidas += 1

        if victoriasX == 2 || victoriasO == 2 {
            ganadorSerie = ganador
            prepararAnuncio(
                titulo: "¡Serie terminada!",
                mensaje: "\(ganador) ganó el mejor de 3. ¡Felicidades!",
                esDeSerie: true
            )
        } else {
            prepararAnuncio(
                titulo: "Ronda terminada",
                mensaje: "Ganó \(ganador). Marcador: X \(victoriasX) — O \(victoriasO)",
                esDeSerie: false
            )
        }
    }

    // ─── SUBVISTA: PANEL DE ESTADÍSTICAS ─────────────────────────────────────────
    //
    // "private var panelEstadisticasView: some View" es una propiedad computada
    // que devuelve una vista. Es la forma idiomática en SwiftUI de extraer
    // bloques grandes del body sin crear un struct nuevo.
    // VENTAJA: comparte acceso al estado del struct padre sin pasarlo como parámetro.
    private var panelEstadisticasView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Estadísticas de sesión")
                .font(.headline)
                .padding(.bottom, 2)

            // Usamos interpolación \() para insertar los valores @State directamente.
            Text("Partidas totales: \(totalPartidas)")
            Text("Victorias X: \(totalVictoriasX)")
                .foregroundStyle(.blue)
            Text("Victorias O: \(totalVictoriasO)")
                .foregroundStyle(.red)
            Text("Empates: \(totalEmpates)")
                .foregroundStyle(.orange)
        }
        .font(.subheadline)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    // Configura el contenido del alert y lo presenta.
    // Separar esta función evita repetir las 4 asignaciones en cada lugar.
    private func prepararAnuncio(titulo: String, mensaje: String, esDeSerie: Bool) {
        tituloAnuncio = titulo
        mensajeAnuncio = mensaje
        anuncioDeSerie = esDeSerie
        // Asignar true a este @State hace que SwiftUI muestre el alert inmediatamente.
        mostrarAnuncio = true
    }

    // Reinicia solo el tablero y estado de ronda.
    // NO toca victorias ni ganadorSerie: la serie continúa.
    private func reiniciarRonda() {
        tablero = Array(repeating: "", count: 9)
        turnoActual = "X"
        estadoJuego = .jugando
    }

    // Reinicia la serie completa: marcador, ganador de serie y ronda.
    // Se llama solo cuando el usuario quiere comenzar una serie nueva desde cero.
    private func reiniciarSerie() {
        victoriasX = 0
        victoriasO = 0
        // Asignamos nil para indicar que aún no hay ganador de la nueva serie.
        // nil en un Optional significa "ausencia de valor": la serie está en curso.
        ganadorSerie = nil
        reiniciarRonda()
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
