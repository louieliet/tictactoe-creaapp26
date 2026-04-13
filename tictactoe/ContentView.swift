//
//  ContentView.swift
//  tictactoe
//
//  Created by Emiliano Montes Gómez on 13/04/26.
//

// ─────────────────────────────────────────────────────────────────────────────
// SESIÓN 1: Fundamentos de Swift + Tablero base
// ─────────────────────────────────────────────────────────────────────────────
// En esta sesión aprendemos:
//   · Variables (var) y constantes (let)
//   · Tipos básicos: String, Int, Bool
//   · Arreglos (Array) y acceso por índice
//   · Condicional básico (if / else)
//   · Estructura de una vista en SwiftUI
// ─────────────────────────────────────────────────────────────────────────────

// "import" le dice a Swift que vamos a usar un conjunto de herramientas ya creadas.
// SwiftUI es el framework de Apple para construir interfaces visuales con código.
// Sin esta línea el compilador no conocería nada: ni View, ni Text, ni VStack.
import SwiftUI


// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTES GLOBALES DEL JUEGO
// ─────────────────────────────────────────────────────────────────────────────

// "let" declara una CONSTANTE: un valor que NO puede cambiar una vez asignado.
// Úsala para datos fijos: títulos, reglas, configuración del juego.
// Si intentas modificarla después, Xcode te dará un error de compilación.
let tituloJuego: String = "Tic Tac Toe"

// "var" declara una VARIABLE: un valor que SÍ puede cambiar en cualquier momento.
// El número de partidas jugadas puede crecer, por eso usamos "var".
// Comparación clave: let = pared de concreto, var = pizarrón borrable.
var partidasJugadas: Int = 0

// Un ARREGLO (Array) es una lista ordenada de elementos del mismo tipo.
// Aquí representamos las 9 celdas del tablero: índice 0 = esquina superior izq,
// índice 8 = esquina inferior derecha. La lectura es de izquierda a derecha:
//   [0][1][2]
//   [3][4][5]
//   [6][7][8]
// "" (cadena vacía) significa que esa celda aún no ha sido jugada.
// Bool que usaremos para ilustrar el tipo: true = partida activa, false = terminada.
let partidaActiva: Bool = true

// Separamos el tablero inicial como constante porque los valores de inicio
// siempre serán los mismos: 9 celdas vacías.
let tableroInicial: [String] = ["", "", "", "", "", "", "", "", ""]


// ─────────────────────────────────────────────────────────────────────────────
// VISTA PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

// "struct" define una ESTRUCTURA: un molde con datos y comportamiento.
// Es el bloque de construcción más común en Swift (junto con "class").
// "ContentView" es el nombre de esta pantalla. Podemos tener muchas vistas.
// ": View" significa que cumple el PROTOCOLO View de SwiftUI, es decir,
// esta estructura "promete" tener una propiedad llamada "body" que describe la UI.
struct ContentView: View {

    // "body" es la propiedad requerida por el protocolo View.
    // "var" porque SwiftUI necesita poder leerla en cualquier momento.
    // "some View" es un tipo opaco: significa "devuelve algún tipo de vista",
    // y Swift infiere cuál exactamente. No necesitamos especificarlo nosotros.
    var body: some View {

        // VStack es un contenedor que apila sus hijos en sentido VERTICAL (↓).
        // "spacing: 24" agrega 24 puntos de espacio entre cada elemento hijo.
        // Sin spacing, los elementos quedarían pegados entre sí.
        VStack(spacing: 24) {

            // MARK: Título
            // "Text" es la vista más básica de SwiftUI: muestra una cadena en pantalla.
            // Pasamos la constante "tituloJuego" en lugar de texto literal para
            // demostrar el uso de constantes dentro de una vista.
            Text(tituloJuego)
                // Los "modifiers" son métodos que aplican cambios al aspecto de la vista.
                // Se encadenan con punto (.) y cada uno devuelve una vista modificada.
                // ".font" controla el tamaño tipográfico con valores semánticos:
                // .caption (pequeño) → .body → .title → .largeTitle (grande)
                .font(.largeTitle)
                // ".fontWeight" controla el grosor del texto.
                .fontWeight(.bold)

            // MARK: Indicador de turno
            // Por ahora mostramos un texto fijo "Turno de: X".
            // En la sesión 2 este texto cambiará dinámicamente con @State.
            // Este es un buen ejemplo de algo que HOY es constante y MAÑANA será variable.
            Text("Turno de: X")
                .font(.title3)
                // ".foregroundStyle" controla el color del contenido de la vista.
                // ".secondary" es un color del sistema que se adapta solo
                // al modo claro u oscuro del dispositivo (no necesitamos hacer nada extra).
                .foregroundStyle(.secondary)

            // MARK: Tablero 3x3
            // Definimos las columnas del grid. Cada "GridItem" representa una columna.
            // ".flexible()" le dice a SwiftUI que reparta el espacio disponible
            // de forma equitativa entre las tres columnas.
            let columnas = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            // LazyVGrid organiza vistas en FILAS Y COLUMNAS (cuadrícula).
            // "Lazy" significa que solo construye las celdas que son visibles:
            // muy eficiente en memoria cuando hay muchos elementos.
            // "spacing: 8" agrega 8 puntos de espacio vertical entre filas.
            LazyVGrid(columns: columnas, spacing: 8) {

                // "ForEach" itera sobre una colección y genera UNA vista por elemento.
                // "0..<9" es un RANGO del 0 al 8 (el operador "..<" excluye el límite superior).
                // "id: \.self" le dice a SwiftUI cómo identificar cada elemento de forma única,
                // necesario para que la UI pueda actualizar sólo las celdas que cambien.
                ForEach(0..<9, id: \.self) { indice in

                    // Por cada índice del 0 al 8 creamos una CeldaView.
                    // Le pasamos el contenido que tiene el tablero en esa posición.
                    // Acceder a un arreglo por índice: tableroInicial[indice]
                    // Si el índice no existe, Swift lanza un error en tiempo de ejecución.
                    CeldaView(contenido: tableroInicial[indice], indice: indice)
                }
            }
            // ".padding(.horizontal)" agrega espacio solo a los lados (izquierda y derecha).
            // Evita que el tablero toque los bordes físicos de la pantalla.
            .padding(.horizontal)

            // MARK: Información de sesión (solo educativo)
            // Mostramos algunas variables para que los alumnos vean su valor en pantalla.
            // "\(variable)" es INTERPOLACIÓN DE CADENAS: incrusta el valor de una variable
            // dentro de un String usando la sintaxis \( ).
            VStack(spacing: 4) {
                Text("Partidas jugadas: \(partidasJugadas)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // El OPERADOR TERNARIO es un "if" compacto en una sola línea:
                // condición ? valor_si_true : valor_si_false
                // Es equivalente a escribir un if/else completo pero más conciso.
                Text("Partida activa: \(partidaActiva ? "Sí" : "No")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        // ".padding()" sin parámetros agrega espacio uniforme en los 4 lados del VStack.
        .padding()
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// VISTA DE CELDA INDIVIDUAL
// ─────────────────────────────────────────────────────────────────────────────

// Separar la celda en su propio struct es una práctica importante:
// → Responsabilidad única: esta vista SOLO sabe mostrarse a sí misma.
// → Reutilizable: podemos crear tantas CeldaView como necesitemos.
// → Legible: ContentView queda limpio y fácil de leer.
// Este es el primer principio de POO que veremos en el taller.
struct CeldaView: View {

    // Propiedades constantes: la celda recibe estos datos desde quien la crea (ContentView).
    // Este patrón se llama "paso de datos de padre a hijo" (parent → child).
    // "let" porque la vista no modifica estos valores, solo los muestra.
    let contenido: String  // Qué tiene la celda: "", "X" o "O"
    let indice: Int        // Qué posición del tablero representa (0-8)

    var body: some View {

        // ZStack apila sus hijos en el eje Z (profundidad), uno ENCIMA del otro.
        // Aquí lo usamos para colocar el texto (X, O o número) sobre el fondo visual.
        ZStack {

            // RoundedRectangle es una figura geométrica: rectángulo con esquinas redondeadas.
            // "cornerRadius: 12" controla qué tan redondeadas son las esquinas.
            // A mayor número, más redondeadas (0 = sin redondeo = ángulos rectos).
            RoundedRectangle(cornerRadius: 12)
                // ".fill" rellena la figura con un color sólido o semitransparente.
                // ".opacity(0.12)" hace el color casi transparente.
                // Escala: 0.0 = completamente invisible, 1.0 = completamente sólido.
                .fill(.blue.opacity(0.12))
                // ".aspectRatio(1, contentMode: .fit)" fuerza a que la celda sea CUADRADA.
                // "1" = razón ancho:alto = 1:1. Si el ancho es 100pt, el alto también será 100pt.
                // ".fit" indica que debe caber dentro del espacio disponible sin recortarse.
                .aspectRatio(1, contentMode: .fit)

            // "if / else" evalúa una condición y ejecuta código según el resultado.
            // Esta es la estructura de control más fundamental en programación.
            // ".isEmpty" es una propiedad del tipo String que devuelve:
            //   true  → si la cadena no tiene ningún carácter (ej. "")
            //   false → si tiene al menos uno (ej. "X", "hola", "123")
            if contenido.isEmpty {
                // Celda vacía: mostramos el índice en gris tenue.
                // Esto ayuda a visualizar las posiciones del arreglo durante el taller.
                Text("\(indice)")
                    .font(.caption)
                    .foregroundStyle(.gray.opacity(0.35))
            } else {
                // Celda ocupada: mostramos "X" o "O" en grande.
                Text(contenido)
                    // ".system(size:weight:)" define tamaño y peso tipográfico exactos en puntos.
                    // Usamos esto cuando los tamaños semánticos (.title, etc.) no son suficientes.
                    .font(.system(size: 48, weight: .bold))
                    // Operador ternario para colorear según el jugador:
                    // Si el contenido es "X" → azul, si es cualquier otra cosa → rojo.
                    .foregroundStyle(contenido == "X" ? .blue : .red)
            }
        }
        // ".onTapGesture" registra una acción que se ejecuta cuando el usuario toca la vista.
        // El bloque "{ }" es un CLOSURE: una función sin nombre que se ejecuta en ese momento.
        // Por ahora solo imprimimos en consola para confirmar que el toque funciona.
        // En sesión 2 aquí irá la lógica real de registrar la jugada.
        .onTapGesture {
            // "print()" envía un mensaje a la consola de Xcode (panel inferior "Debug Area").
            // Es la herramienta más básica de depuración: muestra el estado en cualquier momento.
            // La interpolación "\(indice)" y "\(contenido)" muestran los valores reales.
            print("Celda tocada → índice: \(indice) | contenido actual: '\(contenido)'")
        }
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

// #Preview es una macro de Xcode que permite ver la vista en el Canvas
// sin necesidad de correr el app en el simulador.
// Solo existe en tiempo de desarrollo; no afecta el app final.
#Preview {
    ContentView()
}
