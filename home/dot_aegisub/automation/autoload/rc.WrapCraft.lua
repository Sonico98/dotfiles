script_name="WrapCraft"
script_description="Envuelve el texto con llaves `{}`, ofreciendo la opción de eliminar o conservar etiquetas."
script_author="CiferrC"
script_version="1.0"

menu_embedding = "CiferrC/"

-- Constantes Globales para reemplazo de caracteres
local NOTEMDASH = "NOTEMDASH"
local FIRSTCLIP = "FIRSTCLIP"
local LASTCLIP  = "LASTCLIP"
local BR        = "_br_"

-- Función para reemplazar o restaurar caracteres especiales
function reemplazar_caracteres_especiales(texto, modo)
    if modo == "codificar" then
        return texto:gsub("-", NOTEMDASH)
                    :gsub("%(", FIRSTCLIP)
                    :gsub("%)", LASTCLIP)
                    :gsub("\\N", BR)
    else
        return texto:gsub(NOTEMDASH, "-")
                    :gsub(FIRSTCLIP, "%(")
                    :gsub(LASTCLIP, "%)")
                    :gsub(BR, "\\N")
    end
end

-- Función para eliminar las llaves, conservando el contenido interno
function RemoverCorchetes(subs, sel)
    for x, i in ipairs(sel) do
        local linea = subs[i]
        linea.text = reemplazar_caracteres_especiales(linea.text, "codificar") 
        linea.text = linea.text:gsub("{", ""):gsub("}", "")
        linea.text = reemplazar_caracteres_especiales(linea.text, "decodificar")
        subs[i] = linea
    end
end

-- Función para reorganizar las etiquetas y el texto de las líneas seleccionadas
function ReestructurarTexto(subs, sel, eliminarEtiquetas)
    for x, i in ipairs(sel) do
        local linea = subs[i]
        linea.text = reemplazar_caracteres_especiales(linea.text, "codificar")
        
        -- Aquí va todo el proceso de reorganización de etiquetas y comentarios
        linea.text = linea.text
            :gsub("{<([^\\}]-)>}","{%1}")                -- Restaurar comentario
            :gsub("{([^\\}]-)}","}{<%1>}{")              -- Conservar comentario
            :gsub("{<>|([^\\}]-)|<>}","{<%1>}")          -- Conservar comentario previo
            :gsub("{<>([^\\}]-)<>}","%1")                -- Conservar comentario previo
            :gsub("^([^{]+)","{%1")                      -- Primera { cuando no hay etiquetas
            :gsub("([^}]+)$","%1}")                      -- Última } en última columna
            :gsub("([^}])({\\[^}]-})([^{])","%1}%2{%3")  -- Mantener {} alrededor de las etiquetas
            :gsub("^({\\[^}]-})([^{])","%1{%2")          -- Primera { después del primer conjunto de etiquetas
            :gsub("([^}])({\\[^}]-})$","%1}%2")
            :gsub("{}","")                               -- Eliminar llaves vacías
            :gsub("_br_","\\N")                          -- Devolver salto de línea

        if eliminarEtiquetas then
            linea.text = linea.text:gsub("}{\\[^}]-}{",""):gsub("{\\[^}]-}","")
        end

        linea.text = reemplazar_caracteres_especiales(linea.text, "decodificar")
        
        subs[i] = linea
    end
end

-- Función para mostrar un diálogo al usuario
local function MostrarDialogo(subs, sel)
    local configuracion_dialogo = {
        {class="label", label="¿Desea conservar las etiquetas?", x=0, y=0},
        {class="checkbox", label="Sí", name="conservar_etiquetas", value=true, x=0, y=1},
    }
    
    local btn, resultados_usuario = aegisub.dialog.display(configuracion_dialogo)
    
    if btn then
        local eliminarEtiquetas = not resultados_usuario.conservar_etiquetas
        ReestructurarTexto(subs, sel, eliminarEtiquetas)
    end
end

-- Registrar la función MostrarDialogo como una macro en Aegisub
aegisub.register_macro(menu_embedding..script_name, script_description, MostrarDialogo)