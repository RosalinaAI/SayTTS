import asyncio

from openai import AsyncOpenAI

openai = AsyncOpenAI(
    base_url="http://localhost:8080/v1",
    api_key="dummy-key"  # Local server doesn't need real key
)

async def main() -> None:
    with open("../../Media/russian.wav", "rb") as f:
        translation = await openai.audio.translations.create(
            model="ru_RU",
            file=f,
        )

        print(translation.text)

if __name__ == "__main__":
    asyncio.run(main())
