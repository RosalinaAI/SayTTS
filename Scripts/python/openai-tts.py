import asyncio

from openai import AsyncOpenAI
from openai.helpers import LocalAudioPlayer

openai = AsyncOpenAI(
    base_url="http://localhost:8080/v1",
    api_key="dummy-key"  # Local server doesn't need real key
)

async def main() -> None:
    async with openai.audio.speech.with_streaming_response.create(
        model="tts-1",
        voice="alloy", # system voice
        input="The quick brown fox jumps over the lazy dog",
        response_format="pcm",
    ) as response:
        await LocalAudioPlayer().play(response)

if __name__ == "__main__":
    asyncio.run(main())
