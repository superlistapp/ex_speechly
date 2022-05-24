# ExSpeechlyTask

This module implements an example usage for the [Speechly gRPC API](https://docs.speechly.com/speechly-api/).

## Run the example

- [Install Elixir](https://elixir-lang.org/install.html)
- Run `mix deps.get` to install all dependencies.
- Run `iex -S mix` to start an interactive elixir shell.

Now you can call the following function to transcribe the example audio file.

```elixir
iex> ExSpeechlyTask.speech_to_text("priv/test1_en.wav")
"BANANAS APPLES"
```

To transcribe another file make sure it's using the correct format. You can also make use of `ffmpeg` to transform audio files:

```bash
ffmpeg -y -i in.mp4 -acodec pcm_s16le -ac 1 -ar 16000 out.wav
```
