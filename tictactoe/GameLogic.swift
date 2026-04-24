//
//  GameLogic.swift
//  tictactoe
//
//  Created by Emiliano Montes Gómez on 13/04/26.
//

// ─────────────────────────────────────────────────────────────────────────────
// SESIÓN 3: POO básica — Separación de responsabilidades
// ─────────────────────────────────────────────────────────────────────────────
// Este archivo introduce el concepto más importante de POO:
// SEPARACIÓN DE RESPONSABILIDADES (Single Responsibility Principle).
//
// Hasta sesión 2, ContentView hacía todo: mostraba la UI Y contenía la lógica.
// En proyectos reales eso escala muy mal: un archivo de 2000 líneas
// donde conviven botones, colores, reglas y validaciones es una pesadilla.
//
// Hoy separamos en dos responsabilidades claras:
//   · GameLogic.swift → MODELO: conoce las reglas, no sabe nada de UI
//   · ContentView.swift → VISTA: muestra el estado, no conoce las reglas
//
// Pregunta clave para decidir dónde va cada cosa:
//   "¿Esta línea describe CÓMO SE VE algo?" → ContentView
//   "¿Esta línea describe CÓMO FUNCIONA el juego?" → GameLogic
//
// Nuevos conceptos en este archivo:
//   · enum: tipo con casos nombrados y exhaustivos
//   · Valores asociados en enum: datos empaquetados junto con el caso
//   · switch: estructura de control que cubre todos los casos de un enum
//   · struct con funciones static: lógica que no necesita instancia
//   · allSatisfy: verificar que todos los elementos cumplen una condición
//   · Optional (String?): un valor que puede existir o no existir
// ─────────────────────────────────────────────────────────────────────────────

// Foundation es el framework base de Apple: números, fechas, colecciones, etc.
// NO importamos SwiftUI aquí porque la lógica del juego no tiene nada visual.
// Eso confirma que la separación está bien hecha: las reglas son independientes de la UI.
import Foundation


// ─────────────────────────────────────────────────────────────────────────────
// ESTADO DEL JUEGO
// ─────────────────────────────────────────────────────────────────────────────

// "enum" define un tipo con un conjunto FIJO y NOMBRADO de casos posibles.
// Es ideal para representar estados mutuamente excluyentes:
// el juego SOLO puede estar en uno de estos tres estados a la vez.
//
// Ventaja sobre usar String o Int para representar el estado:
//   Con String → podrías escribir "Jugandoo" por error, sin ninguna alerta.
//   Con enum → si el caso no existe, Xcode muestra error de compilación.
//   El compilador garantiza que solo uses casos válidos.
enum EstadoJuego {

    // El juego está en curso: todavía hay jugadas posibles.
    case jugando

    // Alguien ganó. "jugador: String" es un VALOR ASOCIADO:
    // datos extra empaquetados junto con el caso.
    // Piénsalo como: el caso "ganador" trae consigo QUIÉN ganó.
    // Así evitamos necesitar una variable suelta "@State var ultimoGanador".
    // Todo lo que describe este estado viaja junto en un solo valor.
    case ganador(jugador: String)

    // Todas las celdas están llenas y nadie ganó.
    case empate

    // ─── PROPIEDAD COMPUTADA DEL ENUM ────────────────────────────────────────
    //
    // Los enum en Swift también pueden tener propiedades y funciones.
    // "estaJugando" devuelve true solo si el estado actual es ".jugando".
    // ContentView lo usará en guard para bloquear jugadas al terminar.
    //
    // "if case .jugando = self" es PATTERN MATCHING:
    // pregunta "¿el valor actual de este enum coincide con el caso .jugando?"
    // "self" dentro de un enum/struct se refiere al valor actual (sí mismo).
    var estaJugando: Bool {
        if case .jugando = self { return true }
        return false
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// LÓGICA DEL JUEGO
// ─────────────────────────────────────────────────────────────────────────────

// "struct GameLogic" agrupa todas las funciones que describen las REGLAS del juego.
// No almacena ningún estado propio: recibe el tablero, evalúa y devuelve resultado.
//
// Sus funciones son "static": se llaman directamente desde el tipo,
// sin necesitar crear una instancia con GameLogic().
// Ejemplo de uso: GameLogic.verificarGanador(en: tablero)
//
// Analogía: GameLogic es como el reglamento oficial del Tic Tac Toe.
// No "juega" por sí solo, pero cualquiera puede consultarlo.
struct GameLogic {

    // Las 8 combinaciones de índices que representan una línea ganadora.
    // Cada subarray contiene los 3 índices que forman una línea en el tablero.
    //
    // Recordemos el mapa de posiciones del tablero:
    //   [0][1][2]   ← fila superior
    //   [3][4][5]   ← fila del medio
    //   [6][7][8]   ← fila inferior
    //
    // "static let" porque es configuración del juego: nunca cambia
    // y pertenece al TIPO (GameLogic), no a instancias individuales.
    static let combinacionesGanadoras: [[Int]] = [
        [0, 1, 2],  // fila superior
        [3, 4, 5],  // fila del medio
        [6, 7, 8],  // fila inferior
        [0, 3, 6],  // columna izquierda
        [1, 4, 7],  // columna central
        [2, 5, 8],  // columna derecha
        [0, 4, 8],  // diagonal principal  ↘
        [2, 4, 6]   // diagonal secundaria ↙
    ]

    // ─── VERIFICAR GANADOR ────────────────────────────────────────────────────
    //
    // Recorre todas las combinaciones ganadoras y verifica si alguna está completa.
    //
    // "-> String?" es un OPTIONAL: el "?" indica que el valor puede existir o NO.
    //   · Devuelve "X" o "O" si encontró ganador.
    //   · Devuelve nil ("ningún valor") si no hay ganador todavía.
    //
    // Optional es más semántico y seguro que devolver "" o "ninguno":
    // el compilador te obliga a manejar ambos casos al usar el resultado.
    static func verificarGanador(en tablero: [String]) -> String? {

        // Iteramos sobre cada una de las 8 combinaciones ganadoras.
        for combinacion in combinacionesGanadoras {

            // Extraemos los tres índices de esta combinación con nombres descriptivos.
            // Es mejor leer "tablero[a]" que "tablero[combinacion[0]]".
            let a = combinacion[0]
            let b = combinacion[1]
            let c = combinacion[2]

            // Si la primera celda está vacía, esta línea no puede ser ganadora.
            // "continue" salta al siguiente ciclo del for sin ejecutar el resto.
            // Es más eficiente que llegar a la comparación sabiendo que fallará.
            guard !tablero[a].isEmpty else { continue }

            // Si los tres valores son iguales entre sí, hay ganador.
            // No podemos escribir a == b == c en Swift como en matemáticas,
            // así que comparamos en dos pasos: a==b Y b==c.
            // Si a==b y b==c, entonces por transitividad a==b==c.
            if tablero[a] == tablero[b] && tablero[b] == tablero[c] {
                // Devolvemos el símbolo del ganador: "X" u "O".
                // Usamos tablero[a] en lugar de una cadena literal
                // para que funcione con cualquier símbolo de jugador.
                return tablero[a]
            }
        }

        // Si recorrimos todas las combinaciones sin encontrar ganador → nil.
        return nil
    }

    // ─── VERIFICAR EMPATE ─────────────────────────────────────────────────────
    //
    // Devuelve true si todas las celdas están ocupadas.
    // Se debe llamar SOLO DESPUÉS de verificar que no hay ganador,
    // porque si hay ganador no es empate aunque el tablero esté lleno.
    //
    // "allSatisfy" es un método de Array que devuelve true SOLO SI
    // TODOS los elementos del arreglo cumplen la condición del closure.
    // Si al menos uno no la cumple, devuelve false inmediatamente.
    //
    // "$0" es el nombre automático del elemento actual en un closure de una línea.
    // Equivale a: tablero.allSatisfy { celda in !celda.isEmpty }
    static func verificarEmpate(en tablero: [String]) -> Bool {
        return tablero.allSatisfy { !$0.isEmpty }
    }
}
