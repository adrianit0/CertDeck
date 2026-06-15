/**
 * Lógica pura para el ejercicio de respuesta escrita (`text_input`).
 *
 * Pensado para respuestas de 1 palabra o 1 número. La comparación es
 * tolerante: ignora mayúsculas/minúsculas, espacios sobrantes y tildes /
 * diacríticos, de modo que un usuario sin "ñ" pueda escribir "n" y un
 * acento de más o de menos no invalide la respuesta.
 *
 * Ejemplo: respuesta correcta "España" ⇄ el usuario escribe " éspanA"
 * → ambas se normalizan a "espana" y se consideran iguales.
 *
 * Es lógica crítica y se testea como función pura (RNF-09).
 */

// Bloque Unicode de marcas diacríticas combinantes (tildes, diéresis, la
// tilde de la "ñ", la cedilla, etc.) que se eliminan tras descomponer (NFD).
const COMBINING_MARKS = /[̀-ͯ]/g;

/**
 * Normaliza una respuesta para compararla:
 *  - descompone (NFD) y elimina los diacríticos;
 *  - pasa a minúsculas;
 *  - colapsa espacios internos repetidos y recorta los extremos.
 */
export function normalizeAnswer(value: string): string {
  return value
    .normalize("NFD")
    .replace(COMBINING_MARKS, "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

/** Compara la respuesta del usuario con la correcta de forma tolerante. */
export function isTextAnswerCorrect(correct: string, userAnswer: string): boolean {
  return normalizeAnswer(correct) === normalizeAnswer(userAnswer);
}

/**
 * Índices de los caracteres "de letra" (no espacios) dentro de la respuesta.
 * Se usa para elegir qué hueco revelar como pista sin caer en un espacio.
 */
export function letterIndices(chars: readonly string[]): number[] {
  const indices: number[] = [];
  for (let i = 0; i < chars.length; i++) {
    if (!/\s/.test(chars[i] as string)) indices.push(i);
  }
  return indices;
}

/**
 * Elige al azar el índice de una letra a revelar como pista. Devuelve `null`
 * si la respuesta no tiene letras (caso degenerado).
 */
export function pickHintIndex(chars: readonly string[]): number | null {
  const indices = letterIndices(chars);
  if (indices.length === 0) return null;
  return indices[Math.floor(Math.random() * indices.length)] as number;
}
