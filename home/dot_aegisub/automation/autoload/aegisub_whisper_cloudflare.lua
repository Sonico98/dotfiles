script_name = "Cloudflare Whisper Transcribe"
script_description = "Transcribe selected subtitle lines with Cloudflare Workers AI Whisper and overwrite line text"
script_author = "GitHub Copilot"
script_version = "0.1.0"

math.randomseed(os.time())

local CONFIG_DIR = aegisub.decode_path("?user") .. "/automation"
local CONFIG_PATH = CONFIG_DIR .. "/cloudflare_whisper.conf"

local function sh_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function file_exists(path)
  local f = io.open(path, "rb")
  if f then
    f:close()
    return true
  end
  return false
end

local function read_all(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local data = f:read("*a")
  f:close()
  return data
end

local function write_all(path, data)
  local f = io.open(path, "wb")
  if not f then
    return false
  end
  f:write(data)
  f:close()
  return true
end

local function run_capture(cmd)
  local p = io.popen(cmd .. " 2>&1")
  if not p then
    return false, "Failed to start command"
  end
  local out = p:read("*a")
  local ok, why, code = p:close()
  if ok == nil then
    return false, out, code or 1
  end
  return true, out, 0
end

local function trim(s)
  local t = (s or ""):gsub("^%s+", "")
  t = t:gsub("%s+$", "")
  return t
end

local function parse_bool(v)
  return v == "1" or v == "true" or v == "yes"
end

local function strip_ass_tags(text)
  local s = tostring(text or "")
  s = s:gsub("{[^}]*}", "")
  s = s:gsub("\\N", " ")
  s = s:gsub("\\n", " ")
  s = s:gsub("\\h", " ")
  return trim(s)
end

local function normalize_account_id(v)
  local s = trim(v or "")
  s = s:gsub("^['\"]", ""):gsub("['\"]$", "")
  s = s:gsub("^%(", ""):gsub("%)$", "")
  s = s:gsub("^%{", ""):gsub("%}$", "")
  s = s:gsub("%s+", "")
  return s
end

local function is_valid_account_id(v)
  local s = normalize_account_id(v)
  -- Cloudflare account ID is typically a 32-char lowercase hex string.
  return s:match("^[0-9a-fA-F]+$") and #s >= 20
end

local function load_config()
  local cfg = {
    account_id = "",
    api_token = "",
    language = "ja",
    model = "whisper-large-v3-turbo",
    batch_enabled = true,
    silence_ms = 250,
    max_batch_lines = 12
  }

  local raw = read_all(CONFIG_PATH)
  if not raw then
    return cfg
  end

  for line in raw:gmatch("[^\r\n]+") do
    local k, v = line:match("^([^=]+)=(.*)$")
    if k and v then
      if k == "account_id" then cfg.account_id = v end
      if k == "api_token" then cfg.api_token = v end
      if k == "language" then cfg.language = v end
      if k == "model" then cfg.model = v end
      if k == "batch_enabled" then cfg.batch_enabled = parse_bool(v) end
      if k == "silence_ms" then cfg.silence_ms = tonumber(v) or cfg.silence_ms end
      if k == "max_batch_lines" then cfg.max_batch_lines = tonumber(v) or cfg.max_batch_lines end
    end
  end

  return cfg
end

local function save_config(cfg)
  os.execute("mkdir -p " .. sh_quote(CONFIG_DIR))
  local payload = table.concat({
    "account_id=" .. (cfg.account_id or ""),
    "api_token=" .. (cfg.api_token or ""),
    "language=" .. (cfg.language or "ja"),
    "model=" .. (cfg.model or "whisper-large-v3-turbo"),
    "batch_enabled=" .. ((cfg.batch_enabled and "1") or "0"),
    "silence_ms=" .. tostring(cfg.silence_ms or 250),
    "max_batch_lines=" .. tostring(cfg.max_batch_lines or 12)
  }, "\n") .. "\n"

  return write_all(CONFIG_PATH, payload)
end

local function check_dependencies()
  local required = { "ffmpeg", "curl" }
  local missing = {}

  for _, bin in ipairs(required) do
    local ok = os.execute("command -v " .. bin .. " >/dev/null 2>&1")
    if not ok then
      table.insert(missing, bin)
    end
  end

  return missing
end

local function config_dialog(cfg)
  local dialog = {
    { class = "label", x = 0, y = 0, width = 4, height = 1, label = "Cloudflare Workers AI configuration" },
    { class = "label", x = 0, y = 1, width = 1, height = 1, label = "Account ID (not Account Number)" },
    { class = "edit", name = "account_id", x = 1, y = 1, width = 3, height = 1, value = cfg.account_id },

    { class = "label", x = 0, y = 2, width = 1, height = 1, label = "API token" },
    { class = "edit", name = "api_token", x = 1, y = 2, width = 3, height = 1, value = cfg.api_token },

    { class = "label", x = 0, y = 3, width = 1, height = 1, label = "Language" },
    { class = "edit", name = "language", x = 1, y = 3, width = 1, height = 1, value = cfg.language },
    { class = "label", x = 2, y = 3, width = 2, height = 1, label = "Use ja for Japanese" },

    { class = "label", x = 0, y = 4, width = 1, height = 1, label = "Model" },
    { class = "edit", name = "model", x = 1, y = 4, width = 3, height = 1, value = cfg.model },

    { class = "checkbox", name = "batch_enabled", x = 0, y = 5, width = 2, height = 1, label = "Batch consecutive selected lines", value = cfg.batch_enabled },

    { class = "label", x = 0, y = 6, width = 2, height = 1, label = "Silence between clips (ms)" },
    { class = "intedit", name = "silence_ms", x = 2, y = 6, width = 1, height = 1, value = cfg.silence_ms, min = 50, max = 2000 },

    { class = "label", x = 0, y = 7, width = 2, height = 1, label = "Max lines per batch" },
    { class = "intedit", name = "max_batch_lines", x = 2, y = 7, width = 1, height = 1, value = cfg.max_batch_lines, min = 1, max = 100 }
  }

  local btn, res = aegisub.dialog.display(dialog, { "Save", "Cancel" }, { ok = "Save", cancel = "Cancel" })
  if btn ~= "Save" then
    return nil
  end

  cfg.account_id = normalize_account_id(res.account_id)
  cfg.api_token = trim(res.api_token)
  cfg.language = trim(res.language)
  cfg.model = trim(res.model)
  cfg.batch_enabled = res.batch_enabled
  cfg.silence_ms = tonumber(res.silence_ms) or 250
  cfg.max_batch_lines = tonumber(res.max_batch_lines) or 12

  if cfg.account_id == "" or cfg.api_token == "" then
    aegisub.cancel("Account ID and API token are required")
  end

  if not is_valid_account_id(cfg.account_id) then
    aegisub.cancel("Account ID looks invalid. Use Cloudflare Account ID (hex), not Account Number.")
  end

  if cfg.language == "" then
    cfg.language = "ja"
  end

  if cfg.model == "" then
    cfg.model = "whisper-large-v3-turbo"
  end

  if not save_config(cfg) then
    aegisub.cancel("Failed to save config to " .. CONFIG_PATH)
  end

  return cfg
end

local function ts_to_seconds(ts)
  local h, m, s, ms = ts:match("(%d+):(%d+):(%d+),(%d+)")
  if not h then
    return nil
  end
  return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s) + tonumber(ms) / 1000
end

local function parse_srt(srt)
  local cues = {}
  local block = {}

  local function flush_block()
    if #block == 0 then
      return
    end

    local timing
    local text_lines = {}
    for _, line in ipairs(block) do
      if not timing and line:find("%-%-%>") then
        timing = line
      elseif timing and trim(line) ~= "" then
        table.insert(text_lines, trim(line))
      end
    end

    if timing then
      local start_ts, end_ts = timing:match("(%d+:%d+:%d+,%d+)%s*%-%-%>%s*(%d+:%d+:%d+,%d+)")
      local s = start_ts and ts_to_seconds(start_ts)
      local e = end_ts and ts_to_seconds(end_ts)
      if s and e then
        table.insert(cues, {
          start_s = s,
          end_s = e,
          text = table.concat(text_lines, " ")
        })
      end
    end

    block = {}
  end

  for raw_line in (srt .. "\n"):gmatch("([^\n]*)\n") do
    local line = raw_line:gsub("\r$", "")
    if trim(line) == "" then
      flush_block()
    else
      table.insert(block, line)
    end
  end

  return cues
end

local function extract_text_from_srt(srt)
  local cues = parse_srt(srt)
  local parts = {}
  for _, cue in ipairs(cues) do
    if trim(cue.text) ~= "" then
      table.insert(parts, cue.text)
    end
  end
  return trim(table.concat(parts, " "))
end

local function json_unescape_basic(s)
  if not s then
    return ""
  end
  local out = s
  out = out:gsub('\\"', '"')
  out = out:gsub("\\/", "/")
  out = out:gsub("\\n", "\n")
  out = out:gsub("\\r", "\r")
  out = out:gsub("\\t", "\t")
  out = out:gsub("\\b", "\b")
  out = out:gsub("\\f", "\f")
  out = out:gsub("\\\\", "\\")
  return out
end

local function extract_json_text_fields(raw)
  local parts = {}
  for encoded in raw:gmatch('"text"%s*:%s*"(.-)"') do
    local t = trim(json_unescape_basic(encoded))
    if t ~= "" then
      table.insert(parts, t)
    end
  end

  for encoded in raw:gmatch('"response"%s*:%s*"(.-)"') do
    local t = trim(json_unescape_basic(encoded))
    if t ~= "" then
      table.insert(parts, t)
    end
  end

  return parts
end

local function extract_primary_text_from_json(raw)
  local body = trim(raw or "")
  if body == "" or body:sub(1, 1) ~= "{" then
    return ""
  end

  local result_obj = body:match('"result"%s*:%s*(%b{})')
  if result_obj then
    local encoded = result_obj:match('"text"%s*:%s*"(.-)"')
    if encoded and encoded ~= "" then
      return trim(json_unescape_basic(encoded))
    end
  end

  local top_text = body:match('"text"%s*:%s*"(.-)"')
  if top_text and top_text ~= "" then
    return trim(json_unescape_basic(top_text))
  end

  return ""
end

local function extract_cues_from_json_segments(raw)
  local cues = {}

  -- Common verbose JSON shape: {"start":x,"end":y,"text":"..."}
  for start_s, end_s, encoded in raw:gmatch('"start"%s*:%s*([%d%.]+)%s*,%s*"end"%s*:%s*([%d%.]+)%s*,%s*"text"%s*:%s*"(.-)"') do
    local text = trim(json_unescape_basic(encoded))
    if text ~= "" then
      table.insert(cues, {
        start_s = tonumber(start_s) or 0,
        end_s = tonumber(end_s) or 0,
        text = text
      })
    end
  end

  -- Alternative shape used by some APIs: "timestamp":[x,y],"text":"..."
  if #cues == 0 then
    for start_s, end_s, encoded in raw:gmatch('"timestamp"%s*:%s*%[%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%]%s*,%s*"text"%s*:%s*"(.-)"') do
      local text = trim(json_unescape_basic(encoded))
      if text ~= "" then
        table.insert(cues, {
          start_s = tonumber(start_s) or 0,
          end_s = tonumber(end_s) or 0,
          text = text
        })
      end
    end
  end

  return cues
end

local function unwrap_cloudflare_payload(raw)
  local body = trim(raw)
  if body == "" then
    return ""
  end

  -- Direct SRT/plain text responses.
  if body:find("%-%-%>") then
    return body
  end
  if body:sub(1, 1) ~= "{" then
    return body
  end

  -- Cloudflare often wraps model output in JSON under result.text/result.response.
  local fields = extract_json_text_fields(body)
  if #fields > 0 then
    return trim(table.concat(fields, "\n"))
  end

  return body
end

local function extract_text_from_response(raw)
  local direct_json_text = extract_primary_text_from_json(raw)
  if direct_json_text ~= "" then
    return direct_json_text
  end

  local payload = unwrap_cloudflare_payload(raw)
  if payload == "" then
    return ""
  end

  -- Only treat as subtitle text if payload is not JSON.
  if payload:sub(1, 1) ~= "{" and payload:find("%-%-%>") then
    return extract_text_from_srt(payload)
  end

  return trim(payload)
end

local function extract_cues_from_response(raw)
  local body = trim(raw)
  if body == "" then
    return {}
  end

  if body:sub(1, 1) == "{" then
    local json_cues = extract_cues_from_json_segments(body)
    if #json_cues > 0 then
      return json_cues
    end
  end

  local payload = unwrap_cloudflare_payload(body)
  if payload:find("%-%-%>") then
    return parse_srt(payload)
  end

  return {}
end

local function summarize_response_for_error(raw)
  local s = trim(raw or "")
  if s == "" then
    return "<empty response body>"
  end
  s = s:gsub("\r", " "):gsub("\n", " ")
  if #s > 320 then
    s = s:sub(1, 320) .. "..."
  end
  return s
end

local function tmp_path(prefix, suffix)
  local temp_dir = aegisub.decode_path("?temp")
  local token = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
  return string.format("%s/%s_%s%s", temp_dir, prefix, token, suffix or "")
end

local function whisper_request(cfg, audio_path, mime_type, response_format, initial_prompt)
  local out_path = tmp_path("cf_whisper_response", ".txt")
  local upload_mime = trim(mime_type)
  if upload_mime == "" then
    upload_mime = "audio/wav"
  end
  local prompt_text = trim(initial_prompt)

  local function json_escape(s)
    local v = tostring(s or "")
    v = v:gsub("\\", "\\\\")
    v = v:gsub('"', '\\"')
    v = v:gsub("\n", "\\n")
    v = v:gsub("\r", "\\r")
    v = v:gsub("\t", "\\t")
    return v
  end

  local function audio_base64(path)
    local cmd1 = "cat " .. sh_quote(path) .. " | base64 | tr -d '\\n'"
    local ok1, out1 = run_capture(cmd1)
    if ok1 and trim(out1) ~= "" then
      return true, trim(out1)
    end

    local cmd2 = "openssl base64 -A -in " .. sh_quote(path)
    local ok2, out2 = run_capture(cmd2)
    if ok2 and trim(out2) ~= "" then
      return true, trim(out2)
    end

    return false, "Failed to base64-encode audio (requires base64 or openssl)."
  end

  local function route_model_variant(model_name)
    -- Cloudflare routing is sensitive to model identifier format.
    -- Try equivalent route forms for the same configured model only.
    local m = trim(model_name)
    if m == "" then
      m = "whisper-large-v3-turbo"
    end

    local candidates = {}
    local seen = {}
    local function add(x)
      if x ~= "" and not seen[x] then
        seen[x] = true
        table.insert(candidates, x)
      end
    end

    add(m)

    local without_prefix = m:gsub("^@cf/openai/", "")
    add(without_prefix)

    if not m:match("^@cf/openai/") then
      add("@cf/openai/" .. m)
    end

    return candidates
  end

  local function encode_path_segment(value)
    return (value:gsub("([^%w%-%._~])", function(c)
      return string.format("%%%02X", string.byte(c))
    end))
  end

  local function route_url_variants(model_name)
    local base = string.format("https://api.cloudflare.com/client/v4/accounts/%s/ai/run/", cfg.account_id)
    local out = {}
    local seen = {}
    local function add(url)
      if not seen[url] then
        seen[url] = true
        table.insert(out, url)
      end
    end

    -- Variant A: raw model path (keeps slashes).
    add(base .. model_name)
    -- Variant B: fully encoded single path segment.
    add(base .. encode_path_segment(model_name))
    return out
  end

  local function do_request(field_name, url)

    local cmd = table.concat({
      "curl -sS",
      "-o", sh_quote(out_path),
      "-w", sh_quote("%{http_code}"),
      "-X POST",
      sh_quote(url),
      "-H", sh_quote("Authorization: Bearer " .. cfg.api_token),
      "-F", sh_quote(field_name .. "=@" .. audio_path .. ";type=" .. upload_mime),
      "-F", sh_quote("task=transcribe"),
      "-F", sh_quote("language=" .. cfg.language),
      "-F", sh_quote("response_format=" .. response_format)
    }, " ")

    if prompt_text ~= "" then
      cmd = cmd .. " -F " .. sh_quote("initial_prompt=" .. prompt_text)
    end

    local ok, http_code_text = run_capture(cmd)
    local body = read_all(out_path) or ""
    os.remove(out_path)
    if not ok then
      return false, body, 0
    end
    local http_code = tonumber(trim(http_code_text)) or 0
    return http_code >= 200 and http_code < 300, body, http_code
  end

  local function do_request_json_base64(url)
    local ok_b64, b64_or_err = audio_base64(audio_path)
    if not ok_b64 then
      return false, tostring(b64_or_err), 0
    end

    local body_json
    if prompt_text ~= "" then
      body_json = string.format(
        '{"audio":"%s","language":"%s","response_format":"%s","initial_prompt":"%s"}',
        json_escape(b64_or_err),
        json_escape(cfg.language),
        json_escape(response_format),
        json_escape(prompt_text)
      )
    else
      body_json = string.format(
        '{"audio":"%s","language":"%s","response_format":"%s"}',
        json_escape(b64_or_err),
        json_escape(cfg.language),
        json_escape(response_format)
      )
    end

    local cmd = table.concat({
      "curl -sS",
      "-o", sh_quote(out_path),
      "-w", sh_quote("%{http_code}"),
      "-X POST",
      sh_quote(url),
      "-H", sh_quote("Authorization: Bearer " .. cfg.api_token),
      "-H", sh_quote("Content-Type: application/json"),
      "--data", sh_quote(body_json)
    }, " ")

    local ok, http_code_text = run_capture(cmd)
    local body = read_all(out_path) or ""
    os.remove(out_path)
    if not ok then
      return false, body, 0
    end
    local http_code = tonumber(trim(http_code_text)) or 0
    return http_code >= 200 and http_code < 300, body, http_code
  end

  local function do_openai_compat_request(model_name)
    local url = string.format(
      "https://api.cloudflare.com/client/v4/accounts/%s/ai/v1/audio/transcriptions",
      cfg.account_id
    )

    local cmd = table.concat({
      "curl -sS",
      "-o", sh_quote(out_path),
      "-w", sh_quote("%{http_code}"),
      "-X POST",
      sh_quote(url),
      "-H", sh_quote("Authorization: Bearer " .. cfg.api_token),
      "-F", sh_quote("file=@" .. audio_path .. ";type=" .. upload_mime),
      "-F", sh_quote("model=" .. model_name),
      "-F", sh_quote("language=" .. cfg.language),
      "-F", sh_quote("response_format=" .. response_format)
    }, " ")

    if prompt_text ~= "" then
      cmd = cmd .. " -F " .. sh_quote("prompt=" .. prompt_text)
    end

    local ok, http_code_text = run_capture(cmd)
    local body = read_all(out_path) or ""
    os.remove(out_path)
    if not ok then
      return false, body, 0, url
    end
    local http_code = tonumber(trim(http_code_text)) or 0
    return http_code >= 200 and http_code < 300, body, http_code, url
  end

  local last_error = ""
  local last_http = 0
  local attempted_models = {}
  local attempted_routes = {}

  for _, model_name in ipairs(route_model_variant(cfg.model)) do
    table.insert(attempted_models, model_name)
    for _, url in ipairs(route_url_variants(model_name)) do
      table.insert(attempted_routes, url)

      local is_turbo = model_name:find("whisper%-large%-v3%-turbo") ~= nil
      local is_run_route = url:find("/ai/run/", 1, true) ~= nil
      if is_turbo and is_run_route then
        local ok_json, body_json, http_json = do_request_json_base64(url)
        if ok_json then
          return true, body_json
        end
        last_http = http_json
        last_error = trim(body_json)
      end

      local ok, body, http = do_request("file", url)
      if ok then
        return true, body
      end

      local fallback_ok, fallback_body, fallback_http = do_request("audio", url)
      if fallback_ok then
        return true, fallback_body
      end

      last_http = fallback_http ~= 0 and fallback_http or http
      last_error = trim(fallback_body ~= "" and fallback_body or body)
    end
  end

  -- Fallback for accounts/routes that expose speech transcription via OpenAI-compatible endpoint.
  if last_error:find("No route for that URI", 1, true) then
    for _, model_name in ipairs(route_model_variant(cfg.model)) do
      local ok_oa, body_oa, http_oa, url_oa = do_openai_compat_request(model_name)
      table.insert(attempted_routes, url_oa .. " [model=" .. model_name .. "]")
      if ok_oa then
        return true, body_oa
      end
      last_http = http_oa
      last_error = trim(body_oa)
    end
  end

  local combined = string.format(
    "HTTP %d: %s (models tried: %s; routes tried: %s)",
    last_http,
    last_error,
    table.concat(attempted_models, ", "),
    table.concat(attempted_routes, " | ")
  )
  if last_error:find("No route for that URI", 1, true) then
    combined = combined .. " | Hint: verify Cloudflare Account ID (hex string) is correct; do not use Account Number."
  end
  return false, combined
end

local function ffmpeg_extract(audio_path, start_s, end_s, out_wav)
  local cmd = string.format(
    "ffmpeg -hide_banner -loglevel error -y -ss %.3f -to %.3f -i %s -ac 1 -ar 16000 -c:a pcm_s16le %s",
    start_s,
    end_s,
    sh_quote(audio_path),
    sh_quote(out_wav)
  )
  local ok, out = run_capture(cmd)
  if not ok or not file_exists(out_wav) then
    return false, out
  end
  return true
end

local function ffmpeg_make_silence(duration_s, out_wav)
  local cmd = string.format(
    "ffmpeg -hide_banner -loglevel error -y -f lavfi -i anullsrc=r=16000:cl=mono -t %.3f -c:a pcm_s16le %s",
    duration_s,
    sh_quote(out_wav)
  )
  local ok, out = run_capture(cmd)
  if not ok or not file_exists(out_wav) then
    return false, out
  end
  return true
end

local function ffmpeg_transcode_mp3(in_audio, out_mp3)
  local cmd = string.format(
    "ffmpeg -hide_banner -loglevel error -y -i %s -vn -ac 1 -ar 16000 -c:a mp3 -b:a 64k -f mp3 %s",
    sh_quote(in_audio),
    sh_quote(out_mp3)
  )
  local ok, out = run_capture(cmd)
  if not ok or not file_exists(out_mp3) then
    return false, out
  end
  return true
end

local function ffmpeg_concat_from_list(list_path, out_wav)
  local cmd = string.format(
    "ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i %s -ac 1 -ar 16000 -c:a pcm_s16le %s",
    sh_quote(list_path),
    sh_quote(out_wav)
  )
  local ok, out = run_capture(cmd)
  if not ok or not file_exists(out_wav) then
    return false, out
  end
  return true
end

local function get_audio_path()
  local props = aegisub.project_properties()
  local audio_path = props and props.audio_file or ""
  audio_path = trim(audio_path)

  if audio_path == "" then
    return nil
  end

  if audio_path:sub(1, 1) == "?" then
    audio_path = aegisub.decode_path(audio_path)
  end

  if not file_exists(audio_path) then
    return nil
  end

  return audio_path
end

local function collect_selected_dialogue_lines(subtitles, selected_lines)
  local items = {}
  for _, idx in ipairs(selected_lines) do
    local line = subtitles[idx]
    if line and line.class == "dialogue" then
      local start_s = (line.start_time or 0) / 1000.0
      local end_s = (line.end_time or 0) / 1000.0
      if end_s > start_s then
        table.insert(items, {
          idx = idx,
          start_s = start_s,
          end_s = end_s,
          dur_s = end_s - start_s
        })
      end
    end
  end

  table.sort(items, function(a, b) return a.idx < b.idx end)
  return items
end

local function build_context_prompt(subtitles, items)
  local lines = {}
  for _, item in ipairs(items) do
    local line = subtitles[item.idx]
    if line and line.class == "dialogue" then
      local text = strip_ass_tags(line.text or "")
      if text ~= "" then
        table.insert(lines, string.format("[%d] %s", item.idx, text))
      end
    end
  end

  if #lines == 0 then
    return nil
  end

  return "English subtitle context:\n" .. table.concat(lines, "\n")
end

local function split_into_consecutive_groups(items, max_group_size)
  local groups = {}
  local current = {}

  for _, item in ipairs(items) do
    local prev = current[#current]
    local is_next = prev and (item.idx == prev.idx + 1)
    if #current == 0 or (is_next and #current < max_group_size) then
      table.insert(current, item)
    else
      table.insert(groups, current)
      current = { item }
    end
  end

  if #current > 0 then
    table.insert(groups, current)
  end

  return groups
end

local function join_group_with_mapping(work_dir, group, silence_ms)
  local silence_s = silence_ms / 1000.0
  local silence_path = work_dir .. "/silence.wav"

  local ok_silence, silence_err = ffmpeg_make_silence(silence_s, silence_path)
  if not ok_silence then
    return nil, nil, "Failed to create silence clip: " .. tostring(silence_err)
  end

  local concat_list_path = work_dir .. "/concat_list.txt"
  local list = {}
  local offsets = {}
  local cursor = 0.0

  for i, item in ipairs(group) do
    local seg_path = string.format("%s/seg_%03d.wav", work_dir, i)
    local ok_seg, seg_err = ffmpeg_extract(item.audio_path, item.start_s, item.end_s, seg_path)
    if not ok_seg then
      return nil, nil, "Failed to extract audio segment: " .. tostring(seg_err)
    end

    offsets[i] = { start_s = cursor, end_s = cursor + item.dur_s }

    table.insert(list, "file " .. sh_quote(seg_path))
    cursor = cursor + item.dur_s

    if i < #group then
      table.insert(list, "file " .. sh_quote(silence_path))
      cursor = cursor + silence_s
    end
  end

  if not write_all(concat_list_path, table.concat(list, "\n") .. "\n") then
    return nil, nil, "Failed to write concat list"
  end

  local joined_path = work_dir .. "/joined.wav"
  local ok_join, join_err = ffmpeg_concat_from_list(concat_list_path, joined_path)
  if not ok_join then
    return nil, nil, "Failed to concatenate audio: " .. tostring(join_err)
  end

  return joined_path, offsets
end

local function assign_batch_cues_to_lines(cues, group, offsets)
  local text_by_line = {}
  for i = 1, #group do
    text_by_line[i] = {}
  end

  for _, cue in ipairs(cues) do
    local mid = (cue.start_s + cue.end_s) / 2.0
    local target = nil
    for i, off in ipairs(offsets) do
      if mid >= off.start_s and mid <= off.end_s then
        target = i
        break
      end
    end

    -- Fallback if midpoint misses due to tiny timing drift: match by overlap.
    if not target then
      local best_i = nil
      local best_overlap = 0
      for i, off in ipairs(offsets) do
        local overlap = math.max(0, math.min(cue.end_s, off.end_s) - math.max(cue.start_s, off.start_s))
        if overlap > best_overlap then
          best_overlap = overlap
          best_i = i
        end
      end
      target = best_i
    end

    if target and trim(cue.text) ~= "" then
      table.insert(text_by_line[target], cue.text)
    end
  end

  local out = {}
  for i = 1, #group do
    out[i] = trim(table.concat(text_by_line[i], " "))
  end
  return out
end

local function transcribe_single_line(cfg, subtitles, audio_path, item, work_dir)
  local clip_path = string.format("%s/single_%d.wav", work_dir, item.idx)
  local ok_extract, extract_err = ffmpeg_extract(audio_path, item.start_s, item.end_s, clip_path)
  if not ok_extract then
    return false, "FFmpeg extract failed: " .. tostring(extract_err)
  end

  local upload_path = clip_path
  local upload_mime = "audio/wav"
  local clip_mp3_path = string.format("%s/single_%d.mp3", work_dir, item.idx)
  local ok_mp3 = ffmpeg_transcode_mp3(clip_path, clip_mp3_path)
  if ok_mp3 then
    upload_path = clip_mp3_path
    upload_mime = "audio/mpeg"
  end

  local context_prompt = build_context_prompt(subtitles, { item })

  local ok_req, body_or_err = whisper_request(cfg, upload_path, upload_mime, "verbose_json", context_prompt)
  if (not ok_req) and tostring(body_or_err):find("response_format", 1, true) then
    ok_req, body_or_err = whisper_request(cfg, upload_path, upload_mime, "srt", context_prompt)
  end
  if not ok_req then
    return false, "Cloudflare request failed: " .. tostring(body_or_err)
  end

  local text = extract_text_from_response(body_or_err)
  if text == "" then
    return false, "Empty transcription. Raw response: " .. summarize_response_for_error(body_or_err)
  end

  return true, text
end

local function process_group_batch(cfg, subtitles, group, work_dir)
  local joined_path, offsets, join_err = join_group_with_mapping(work_dir, group, cfg.silence_ms)
  if not joined_path then
    return false, join_err
  end

  local upload_path = joined_path
  local upload_mime = "audio/wav"
  local joined_mp3_path = work_dir .. "/joined.mp3"
  local ok_mp3 = ffmpeg_transcode_mp3(joined_path, joined_mp3_path)
  if ok_mp3 then
    upload_path = joined_mp3_path
    upload_mime = "audio/mpeg"
  end

  local context_prompt = build_context_prompt(subtitles, group)

  local ok_req, body_or_err = whisper_request(cfg, upload_path, upload_mime, "verbose_json", context_prompt)
  if (not ok_req) and tostring(body_or_err):find("response_format", 1, true) then
    ok_req, body_or_err = whisper_request(cfg, upload_path, upload_mime, "srt", context_prompt)
  end
  if not ok_req then
    return false, "Cloudflare request failed: " .. tostring(body_or_err)
  end

  local cues = extract_cues_from_response(body_or_err)
  if #cues == 0 then
    return false, "No timestamped cues returned. Raw response: " .. summarize_response_for_error(body_or_err)
  end

  local per_line_text = assign_batch_cues_to_lines(cues, group, offsets)
  for i, item in ipairs(group) do
    local text = trim(per_line_text[i])
    if text ~= "" then
      local line = subtitles[item.idx]
      line.text = text
      subtitles[item.idx] = line
    end
  end

  return true, per_line_text
end

local function transcribe_selected_lines(subtitles, selected_lines)
  local cfg = load_config()

  cfg.account_id = normalize_account_id(cfg.account_id)

  if cfg.account_id == "" or cfg.api_token == "" then
    local btn = aegisub.dialog.display({
      { class = "label", x = 0, y = 0, width = 1, height = 2, label = "Cloudflare credentials are not configured yet." }
    }, { "Configure now", "Cancel" })

    if btn ~= "Configure now" then
      aegisub.cancel("Canceled")
    end

    cfg = config_dialog(cfg)
    if not cfg then
      aegisub.cancel("Canceled")
    end
  end

  if not is_valid_account_id(cfg.account_id) then
    aegisub.cancel("Configured Account ID looks invalid. Open Whisper/Configure Cloudflare and use Account ID (hex), not Account Number.")
  end

  local missing = check_dependencies()
  if #missing > 0 then
    aegisub.cancel("Missing dependency(ies): " .. table.concat(missing, ", "))
  end

  local audio_path = get_audio_path()
  if not audio_path then
    aegisub.cancel("Could not resolve currently opened audio path. Open audio in Aegisub first.")
  end

  if #selected_lines == 0 then
    aegisub.cancel("Select at least one subtitle line")
  end

  local items = collect_selected_dialogue_lines(subtitles, selected_lines)
  if #items == 0 then
    aegisub.cancel("No valid dialogue lines with non-zero duration were selected")
  end

  for _, item in ipairs(items) do
    item.audio_path = audio_path
  end

  local groups = split_into_consecutive_groups(items, cfg.max_batch_lines)
  local work_dir = tmp_path("aegisub_whisper", "")
  os.execute("mkdir -p " .. sh_quote(work_dir))

  local total = #items
  local done = 0
  local changed = 0
  local failures = {}

  for _, group in ipairs(groups) do
    aegisub.progress.task(string.format("Transcribing lines %d..%d", group[1].idx, group[#group].idx))

    local did_batch = false
    local batch_text

    if cfg.batch_enabled and #group > 1 then
      local ok_batch, result = process_group_batch(cfg, subtitles, group, work_dir)
      if ok_batch then
        did_batch = true
        batch_text = result
        for i = 1, #group do
          if trim(batch_text[i] or "") ~= "" then
            changed = changed + 1
          end
        end
      end
    end

    if not did_batch then
      for _, item in ipairs(group) do
        local ok_single, text_or_err = transcribe_single_line(cfg, subtitles, audio_path, item, work_dir)
        if ok_single then
          local line = subtitles[item.idx]
          line.text = text_or_err
          subtitles[item.idx] = line
          changed = changed + 1
        else
          table.insert(failures, string.format("Line %d: %s", item.idx, text_or_err))
        end

        done = done + 1
        aegisub.progress.set(done * 100 / total)
        if aegisub.progress.is_cancelled() then
          aegisub.cancel("Canceled")
        end
      end
    else
      for i, item in ipairs(group) do
        if trim(batch_text[i] or "") == "" then
          local ok_single, text_or_err = transcribe_single_line(cfg, subtitles, audio_path, item, work_dir)
          if ok_single then
            local line = subtitles[item.idx]
            line.text = text_or_err
            subtitles[item.idx] = line
            changed = changed + 1
          else
            table.insert(failures, string.format("Line %d: %s", item.idx, text_or_err))
          end
        end

        done = done + 1
        aegisub.progress.set(done * 100 / total)
        if aegisub.progress.is_cancelled() then
          aegisub.cancel("Canceled")
        end
      end
    end
  end

  os.execute("rm -rf " .. sh_quote(work_dir))

  local summary = string.format("Transcribed %d/%d selected line(s).", changed, total)
  if #failures > 0 then
    summary = summary .. "\n\nSome lines failed:\n- " .. table.concat(failures, "\n- ")
  end

  aegisub.dialog.display({
    { class = "textbox", x = 0, y = 0, width = 60, height = 14, value = summary }
  }, { "OK" })
end

local function configure_macro()
  local cfg = load_config()
  cfg = config_dialog(cfg)
  if cfg then
    aegisub.log("Cloudflare Whisper config saved to: %s\n", CONFIG_PATH)
  end
end

aegisub.register_macro("Whisper/Transcribe Selected (Cloudflare)", "Transcribe selected subtitle lines and overwrite line text", transcribe_selected_lines)
aegisub.register_macro("Whisper/Configure Cloudflare", "Set Cloudflare account/API token and transcription options", configure_macro)
