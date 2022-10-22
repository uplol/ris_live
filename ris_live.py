import asyncio
import websockets
import orjson


async def main():
    async for websocket in websockets.connect("wss://ris-live.ripe.net/v1/ws"):

        # Subscribe to everything
        await websocket.send(
            orjson.dumps(
                {
                    "type": "ris_subscribe",
                    "data": {
                        "moreSpecific": True,
                        "socketOptions": {"includeRaw": False},
                    },
                }
            )
        )

        # Blindly process forever!
        try:
            async for message in websocket:
                await process(message)
        except websockets.ConnectionClosed:
            continue


async def process(message):

    data = orjson.loads(message)

    # as `path` may contain mixed data types Array(UInt32 | Array(Uint32)) (see https://ris-live.ripe.net/manual/)
    # check `path` for AS_SET (the array in the array) and pop it into it's own key
    if "path" in data["data"] and data["data"]["path"]:
        if type(data["data"]["path"][-1]) == type(list()):
            data["data"]["as_set"] = data["data"]["path"][-1].copy()
            data["data"]["path"].pop()

    # print and pipe into whatever
    print(orjson.dumps(data["data"]).decode("utf-8"))


if __name__ == "__main__":
    loop = asyncio.new_event_loop()
    loop.run_until_complete(main())
    loop.run_forever()
