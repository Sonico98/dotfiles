-- Script para Aegisub: Diálogos curvos usando \frz
script_name = "Crear Diálogos Curvos"
script_description = "Genera diálogos curvos con opciones de ángulo usando \\frz"
script_author = "Kanela-Kun"
script_version = "2.1"

include("karaskel.lua")

function crear_dialogos_curvos(subs, sel)
    local meta, styles = karaskel.collect_head(subs)
    for _, i in ipairs(sel) do
        local line = subs[i]
        karaskel.preproc_line(subs, meta, styles, line)

        -- Mostrar cuadro de diálogo para capturar parámetros con el nuevo dibujo ASCII
        local resultado, configuracion = aegisub.dialog.display({
            {class="label", label="Ángulo de curva (grados):", x=0, y=0},
            {class="edit", name="angulo_max", value="45", hint="Incluye negativos si es necesario", x=1, y=0},
            {class="label", label="⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⡋⠉⠙⠒⢤⡀⠀⠀⠀⠀⠀⢠⠖⠉⠉⠙⠢⡄⠀\n" ..
                                  "⠀⠀⠀⠀⠀⠀⢀⣼⣟⡒⠒⠀⠀⠀⠀⠀⠙⣆⠀⠀⠀⢠⠃⠀⠀⠀⠀⠀⠹⡄\n" ..
                                  "⠀⠀⠀⠀⠀⠀⣼⠷⠖⠀⠀⠀⠀⠀⠀⠀⠀⠘⡆⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⢷\n" ..
                                  "⠀⠀⠀⠀⠀⠀⣷⡒⠀⠀⢐⣒⣒⡒⠀⣐⣒⣒⣧⠀⢰⠀⠀⢠⢤⢠⡠⠀⢸⠀\n" ..
                                  "⠀⠀⠀⠀⠀⢰⣛⣟⣂⠀⠘⠤⠬⠃⠰⠑⠥⠊⣿⠀⢸⠀⠀⠓⠃⠋⠂⠀⢸⠀\n" ..
                                  "⠀⠀⠀⠀⠀⢸⣿⡿⠤⠀⢸⠁⠀⠀⢀⡆⠀⠀⣿⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⣸\n" ..
                                  "⠀⠀⠀⠀⠀⠈⠿⣯⡭⠀⠸⡀⠀⢀⣀⠀⠀⠀⡟⠀⠀⢸⠀⠀⠀⠀⠀⠀⢠⠏\n" ..
                                  "⠀⠀⠀⠀⠀⠀⠀⠈⢯⡥⠄⢱⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠳⢄⣀⣀⣀⡴⠃⠀\n" ..
                                  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢱⡦⣄⣀⣀⣀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠈⠉⠀⠀⠀⠀\n" ..
                                  "⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⠛⠃⠀⠀⠀⢹⠳⡶⣤⡤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" ..
                                  "⠀⠀⠀⠀⣠⢴⣿⣿⣿⡟⡷⢄⣀⣀⣀⡼⠳⡹⣿⣷⠞⣳⠀⠀⠀⠀⠀⠀⠀⠀\n" ..
                                  "⠀⠀⠀⢰⡯⠭⠹⡟⠿⠧⠷⣄⣀⣟⠛⣦⠔⠋⠛⠛⠋⠙⡆⠀⠀⠀⠀⠀⠀⠀\n" ..
                                  "⠀⠀⢸⣿⠭⠉⠀⢠⣤⠀⠀⠀⠘⡷⣵⢻⠀⠀⠀⠀⣼⠀⣇⠀⠀⠀⠀⠀⠀⠀\n" ..
                                  "⠀⠀⡇⣿⠍⠁⠀⢸⣗⠂⠀⠀⠀⣧⣿⣼⠀⠀⠀⠀⣯⠀⢸⠀⠀⠀⠀⠀⠀⠀", x=0, y=1, width=2, height=15, alignment=1} -- Dibujo completo
        }, {"Aplicar", "Cancelar"})

        if resultado == "Cancelar" then
            aegisub.cancel()
        end

        -- Validar que el valor sea numérico (incluyendo negativos)
        local angulo_max = tonumber(configuracion.angulo_max)
        if not angulo_max then
            aegisub.debug.out("Por favor, ingresa un valor válido para el ángulo (número, incluyendo negativos si es necesario).\n")
            aegisub.cancel()
        end

        -- Generar el texto curvado
        local texto = ""
        local longitud_texto = #line.text_stripped
        local centro = math.ceil(longitud_texto / 2) -- Centro de la curva

        for j = 1, longitud_texto do
            local letra = line.text_stripped:sub(j, j)
            -- Desplazamiento horizontal fijo y cálculo del ángulo
            local offset_x = (j - centro) * 20 -- Separación fija de 20 píxeles
            local angulo = (j - centro) * (angulo_max / (longitud_texto / 2))

            texto = texto .. string.format("{\\pos(%d,%d)\\frz%.2f}%s", line.x + offset_x, line.y, angulo, letra)
        end

        line.text = texto
        subs[i] = line
    end

    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, crear_dialogos_curvos)
