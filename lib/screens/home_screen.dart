import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Necesitarás esto para el icono SVG de la estrella
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:dotted_border/dotted_border.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la fecha actual para mostrarla
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, d \'de\' MMMM', 'es').format(now);
    // Capitalizamos la primera letra del día de la semana (ej. "viernes" -> "Viernes")
    final String capitalizedDate = formattedDate.replaceRange(0, 1, formattedDate[0].toUpperCase());

    return Scaffold(
      // Ya no necesitamos un AppBar predeterminado, construiremos la cabecera personalizada en el body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Equivalente a p-6 sm:p-8 y mx-auto
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea los hijos a la izquierda
          children: [
            // (HEADER) Cabecera con Hopoints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Parte izquierda: Saludo y Fecha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buenos días, Alex',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            // Los colores se gestionan con el tema, pero podemos forzar aquí si es necesario
                            color: Theme.of(context).colorScheme.onBackground, // text-gray-800 dark:text-white
                          ),
                    ),
                    const SizedBox(height: 4.0), // Pequeño espacio entre los textos
                    Text(
                      capitalizedDate,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), // text-gray-500 dark:text-gray-400
                          ),
                    ),
                  ],
                ),
                // Parte derecha: Hopoints y Avatar
                Row(
                  children: [
                    // Contenedor de Hopoints
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // bg-white dark:bg-gray-800/50
                        borderRadius: BorderRadius.circular(999.0), // rounded-full
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // border border-gray-200 dark:border-gray-700
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Para que el Row ocupe solo el espacio necesario
                        children: [
                          // Icono de la estrella (Hopoint icon)
                          // Para el SVG, debes colocar el archivo SVG en la carpeta assets
                          // Más adelante te explico cómo añadir assets
                          SvgPicture.string(
                            '''<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-amber-400 hopoint-icon"><path d="M12 2L15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2z"></path></svg>''',
                            colorFilter: ColorFilter.mode(Colors.amber.shade400, BlendMode.srcIn),
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 8.0), // space-x-2
                          Text(
                            '125',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface, // text-gray-700 dark:text-gray-200
                                ),
                          ),
                          const SizedBox(width: 4.0), // space-x-2
                          Text(
                            'Hopoints',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // text-gray-500 dark:text-gray-400
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0), // space-x-4
                    // Avatar de usuario
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF764BA2),
                        border: Border.all(
                          color: Colors.indigo.shade400, // border-indigo-400
                          width: 2.0,
                        )
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24.0), // mb-6 o gap-6
            // (CARD) Contenedor de la tarjeta
            Container(
              width: double.infinity, // w-full
              padding: const EdgeInsets.all(24.0), // p-6 sm:p-8
              decoration: BoxDecoration(
                // Degradado de fondo (gradient-bg)
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA), // #667eea
                    Color(0xFF764BA2), // #764ba2
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0), // rounded-2xl (16px)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // CAMBIO CLAVE AQUÍ: Usamos un Row principal en lugar de Column
              child: Row( // <-- Cambiamos de Column a Row
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-between
                crossAxisAlignment: CrossAxisAlignment.center, // items-center
                // Para manejar el 'md:flex-row' que implica que en móviles es 'flex-col',
                // y para que el botón baje si no hay espacio, podemos usar un Wrap
                // o un LayoutBuilder para detectar el tamaño de la pantalla.
                // Para simplicidad y la mayoría de los casos de uso, Row es suficiente si esperamos suficiente espacio.
                // Si necesitas que baje automáticamente como 'flex-col' en móvil,
                // necesitaríamos un Column para pantallas pequeñas, o usar un Wrap para que el botón "salte" de línea.
                // Por ahora, vamos a mantenerlo como Row para replicar el 'md:flex-row' por defecto.

                children: [
                  // Contenido de texto (lo que antes estaba en una Column)
                  Expanded( // <-- Es importante para que el texto ocupe el espacio disponible
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Listo para tu chequeo diario?',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Gana 1 Hopoint y acércate a tus metas. Solo te tomará 2 minutos.',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Colors.indigo.shade200,
                              ),
                          // maxLines: 2, // Quitando esto para que el texto fluya libremente
                          // overflow: TextOverflow.ellipsis, // Quitando esto para que el texto fluya libremente
                        ),
                      ],
                    ),
                  ),
                  
                  // Espacio entre el texto y el botón (mt-6 md:mt-0)
                  // En un Row, necesitamos un SizedBox horizontal. Si el botón baja, esto no aplicará.
                  const SizedBox(width: 24.0), // Equivalente a un espacio md:mt-0

                  // Botón "Rellenar Cuestionario"
                  // CAMBIO: Aseguramos el tamaño mínimo y el estilo
                  ElevatedButton(
                    onPressed: () {
                      print('Rellenar Cuestionario presionado');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0), // Ajustado: py-3 px-6 era 12, 24. Probamos 18 vertical para más altura
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                      elevation: 4.0,
                      textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0, // Aumentamos el tamaño de la fuente para que el botón sea más grande
                          ),
                      minimumSize: const Size(0, 56), // Añadido: Altura mínima para el botón (py-3 es 12, si le sumamos el tamaño del texto, esto fuerza una altura)
                                                      // py-3 (12) + texto (aprox 20) = 32. py-6 (24) + texto = 44.
                                                      // El diseño tiene un padding vertical generoso, probemos 18 para el padding, y 56 de altura mínima
                                                      // La altura real puede variar según el tamaño de fuente.
                    ),
                    child: const Text('Rellenar Cuestionario'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0), // mb-6 o gap-6
// ... código anterior (cabecera y módulo cuestionario) ...

            const SizedBox(height: 24.0), // Este es el espacio después del Módulo Cuestionario

            // (2) Modulo Análisis y Plan de Mejora (Bloqueado)
            DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(16.0),
              padding: EdgeInsets.zero,
              strokeWidth: 2.0,
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFF4B5563),
              dashPattern: const [8, 4],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row( // Esta es la Row principal del módulo bloqueado
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // CAMBIO CLAVE AQUÍ: ENVOLVER LA ROW DEL ICONO + TEXTO CON Expanded
                    Expanded( // <-- Añade este Expanded
                      child: Row( // Esta es la Row que causaba el error (línea 257)
                        children: [
                          // Icono de candado
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFF3F4F6)
                                  : const Color(0xFF374151),
                              shape: BoxShape.circle,
                            ),
                            margin: const EdgeInsets.only(right: 20.0),
                            child: Icon(
                              Icons.lock_outline,
                              size: 32.0,
                              color: Colors.indigo.shade400,
                            ),
                          ),
                          // Contenido de texto
                          // Aquí ya NO necesitamos Expanded porque el Row padre ahora tiene un Expanded
                          Column( // <-- Elimina el Expanded que envolvía esta Column
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Análisis y Plan de Mejora',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Desbloquea tu plan personalizado para alcanzar tus metas de bienestar.',
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ), // <-- Cierre del Expanded que añadimos

                    // Espacio entre el texto y el botón
                    const SizedBox(width: 16.0), // Puedes ajustar este espacio si el texto se corta mucho

                    // Botón "Ver Plan (Bloqueado)"
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF374151),
                        foregroundColor: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        elevation: 0,
                      ),
                      child: const Text('Ver Plan (Bloqueado)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0), // Espacio para el siguiente módulo

// ... código anterior (cabecera, módulo cuestionario, módulo plan de mejora) ...

            const SizedBox(height: 24.0), // Este es el espacio después del Módulo Análisis y Plan de Mejora

            // (3) Modulo Streak y Modulo Otros Servicios
            Row( // Usamos un Row para que los dos módulos se pongan uno al lado del otro
              children: [
                // Modulo Streak
                Expanded( // Ocupa la mitad del espacio
                  child: Container(
                    padding: const EdgeInsets.all(24.0), // p-6
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, // bg-white dark:bg-gray-800
                      borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.08), // shadow-md
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row( // Row interna para el icono y el texto
                      children: [
                        Icon(
                          Icons.local_fire_department, // Icono de fuego
                          size: 40.0, // h-10 w-10
                          color: Colors.amber.shade500, // text-amber-500
                        ),
                        const SizedBox(width: 16.0), // space-x-4
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Racha actual',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // text-gray-500 dark:text-gray-400
                                  ),
                            ),
                            const SizedBox(height: 4.0), // Pequeño espacio
                            Text(
                              '14 días seguidos',
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface, // text-gray-800 dark:text-white
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24.0), // Espacio entre los dos módulos (gap-6)

                // Modulo Otros Servicios
                Expanded( // Ocupa la otra mitad del espacio
                  child: Container(
                    padding: const EdgeInsets.all(24.0), // p-6
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, // bg-white dark:bg-gray-800
                      borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.08), // shadow-md
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row( // Row interna para el texto y el botón
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded( // El texto puede expandirse para dar espacio al botón
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Servicios Adicionales',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface, // text-gray-800 dark:text-white
                                    ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Analíticas, tests genéticos y más.',
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // text-gray-500 dark:text-gray-400
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0), // Espacio entre texto y botón
                        ElevatedButton(
                          onPressed: () {
                            print('Explorar Servicios Adicionales');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFF3F4F6) // bg-gray-100 para light
                                : const Color(0xFF374151), // dark:bg-gray-700
                            foregroundColor: Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF4B5563) // text-gray-700
                                : const Color(0xFFD1D5DB), // dark:text-gray-300
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // py-2 px-4
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // rounded-lg
                            ),
                            textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  fontWeight: FontWeight.w600, // font-semibold
                                ),
                            elevation: 0, // No tiene sombra para transiciones
                          ),
                          child: const Text('Explorar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24.0), // Espacio para el siguiente módulo

// ... código anterior (cabecera, módulo cuestionario, módulo plan de mejora, módulos streak y servicios) ...

            const SizedBox(height: 24.0), // Este es el espacio después de los módulos Streak y Otros Servicios

            // (4) Modulo Cuestionarios Anteriores
            Container(
              width: double.infinity, // w-full
              padding: const EdgeInsets.all(24.0), // p-6
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // bg-white dark:bg-gray-800
                borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.08), // shadow-md
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea el título a la izquierda
                children: [
                  Text(
                    'Registros Anteriores',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface, // text-gray-800 dark:text-white
                        ),
                  ),
                  const SizedBox(height: 16.0), // mb-4 (4 unidades de Tailwind, aprox 16px)

                  // Lista de registros
                  Column( // space-y-3 (espacio entre los ítems)
                    children: [
                      // --- Ejemplo de registro completado ---
                      Container(
                        padding: const EdgeInsets.all(12.0), // p-3
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFF9FAFB) // bg-gray-50
                              : const Color(0xFF374151).withOpacity(0.5), // dark:bg-gray-700/50
                          borderRadius: BorderRadius.circular(8.0), // rounded-lg
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jueves, 13 de Junio',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600, // font-semibold
                                    color: Theme.of(context).colorScheme.onSurface, // text-gray-700 dark:text-gray-300
                                  ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '✓ Completado',
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: Colors.green.shade500, // text-green-500
                                        fontWeight: FontWeight.w600, // font-semibold
                                      ),
                                ),
                                const SizedBox(width: 8.0), // space-x-2
                                InkWell( // Para el enlace "Ver"
                                  onTap: () {
                                    print('Ver registro del 13 de Junio');
                                  },
                                  child: Text(
                                    'Ver',
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: Colors.indigo.shade500, // text-indigo-500
                                          fontWeight: FontWeight.w500, // font-medium
                                          decoration: TextDecoration.underline, // hover:underline
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12.0), // space-y-3 (12px)

                      // --- Ejemplo de registro pendiente ---
                      Container(
                        padding: const EdgeInsets.all(12.0), // p-3
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFF9FAFB) // bg-gray-50
                              : const Color(0xFF374151).withOpacity(0.5), // dark:bg-gray-700/50
                          borderRadius: BorderRadius.circular(8.0), // rounded-lg
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Miércoles, 12 de Junio',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                print('Rellenar ahora el cuestionario del 12 de Junio');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFFFFEEEE) // bg-red-100
                                    : const Color(0xFF6B1826).withOpacity(0.4), // dark:bg-red-900/40
                                foregroundColor: Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFFDC2626) // text-red-600
                                    : const Color(0xFFFCA5A5), // dark:text-red-400
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // py-1 px-3
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0), // rounded-lg
                                ),
                                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontWeight: FontWeight.w600, // font-semibold
                                    ),
                                elevation: 0,
                              ),
                              child: const Text('Rellenar ahora'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12.0), // space-y-3 (12px)

                      // --- Otro ejemplo de registro completado ---
                      Container(
                        padding: const EdgeInsets.all(12.0), // p-3
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFF9FAFB) // bg-gray-50
                              : const Color(0xFF374151).withOpacity(0.5), // dark:bg-gray-700/50
                          borderRadius: BorderRadius.circular(8.0), // rounded-lg
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Martes, 11 de Junio',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '✓ Completado',
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: Colors.green.shade500,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(width: 8.0),
                                InkWell(
                                  onTap: () {
                                    print('Ver registro del 11 de Junio');
                                  },
                                  child: Text(
                                    'Ver',
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: Colors.indigo.shade500,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0), // Espacio para el siguiente módulo

// ... código anterior (todos los módulos anteriores) ...

            const SizedBox(height: 24.0), // Este es el espacio después del Módulo Cuestionarios Anteriores

            // (5) Modulo Comunidad y Modulo Colaboración
            Row( // Usamos un Row para que los dos módulos se pongan uno al lado del otro
              children: [
                // Módulo Comunidad (WhatsApp)
                Expanded( // Ocupa la mitad del espacio
                  child: Container(
                    padding: const EdgeInsets.all(24.0), // p-6
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, // bg-white dark:bg-gray-800
                      borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.08), // shadow-md
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column( // Contenido centrado verticalmente
                      crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0), // p-3
                          decoration: const BoxDecoration(
                            color: Colors.green, // bg-green-500
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.only(bottom: 12.0), // mb-3
                          child: SvgPicture.string(
                            '''<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="white"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.894 11.892-1.99-.001-3.951-.5-5.688-1.448l-6.305 1.654zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 4.315 1.731 6.086l-1.096 4.022 4.13-1.082z"/></svg>''',
                            width: 28,
                            height: 28,
                            // Los SVGs de logos suelen tener el fill ya en el path
                            // Si necesitaras cambiar el color, podrías usar colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)
                          ),
                        ),
                        Text(
                          'Únete a la Comunidad',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center, // Centra el texto
                        ),
                        const SizedBox(height: 4.0), // mt-1
                        Text(
                          'Comparte tu viaje y encuentra apoyo en nuestro grupo de WhatsApp.',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                          textAlign: TextAlign.center, // Centra el texto
                          maxLines: 2, // Limita a 2 líneas para evitar desbordamiento
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16.0), // mb-4 (se convierte en SizedBox arriba del botón)
                        ElevatedButton(
                          onPressed: () {
                            print('Unirse al grupo de WhatsApp');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // bg-green-500
                            foregroundColor: Colors.white, // text-white
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // py-2 px-5
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // rounded-lg
                            ),
                            textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  fontWeight: FontWeight.w600, // font-semibold
                                ),
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 0), // w-full
                          ),
                          child: const Text('Unirse al grupo'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24.0), // Espacio entre los dos módulos (gap-6)

                // Módulo Colaboración (Patreon)
                Expanded( // Ocupa la otra mitad del espacio
                  child: Container(
                    padding: const EdgeInsets.all(24.0), // p-6
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, // bg-white dark:bg-gray-800
                      borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.08), // shadow-md
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column( // Contenido centrado verticalmente
                      crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0), // p-3
                          decoration: const BoxDecoration(
                            color: Colors.red, // bg-red-500
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.only(bottom: 12.0), // mb-3
                          child: SvgPicture.string(
                            '''<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="white"><path d="M15.225 1.342c-2.457 0-4.449 1.992-4.449 4.449s1.992 4.449 4.449 4.449 4.449-1.992 4.449-4.449-1.992-4.449-4.449-4.449zm-5.025 2.13h-3.3v16.399h3.3v-16.399z"/></svg>''',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        Text(
                          'Apoya el Proyecto',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Tu apoyo en Patreon nos ayuda a seguir mejorando la aplicación.',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            print('Conviértete en mecenas de Patreon');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // bg-red-500
                            foregroundColor: Colors.white, // text-white
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // py-2 px-5
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // rounded-lg
                            ),
                            textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 0), // w-full
                          ),
                          child: const Text('Conviértete en mecenas'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Opcional: un SizedBox al final si esperas más contenido o un footer
            const SizedBox(height: 24.0),
          ], // Cierre del children de la Column principal
        ), // Cierre de la Column principal
      ), // Cierre de SingleChildScrollView
    ); // Cierre de Scaffold
  }
}