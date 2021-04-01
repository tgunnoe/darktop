#!/usr/bin/env python3

import asyncio
import pprint
import re

import i3ipc.aio as i3ipc

layout = {
    "layout": "splith",
    "nodes": [
        {
            "layout": "splitv",
            "width": 57,
            "nodes": [
                {
                    "swallows": {
                        "app_id": r"^kitty$",
                        "name": r"^BpyTOP$"
                    }
                },
                {
                    "swallows": {
                        "app_id": r"^kitty$",
                        "name": r"^cmatrix$"
                    }
                }
            ]
        },
        {
            "layout": "splitv",
            "width": 43,
            "nodes": [
                {
                    "swallows": {
                        "app_id": r"^kitty$",
                        "name": r"^ranger$"
                    }
                },
            ]
        }
    ]
}

def iter_leaves(subtree):
    for node in subtree["nodes"]:
        node["parent"] = subtree
        if node.get("swallows"):
            yield node
        if children := node.get("nodes"):
            yield from iter_leaves(node)
leaves = list(iter_leaves(layout))

def try_match(con):
    for leaf in leaves:
        if leaf.get("con"):
            continue

        for key, pattern in leaf["swallows"].items():
            if (value := getattr(con, key, None)) is None:
                break
            if re.search(pattern, value) is None:
                break
        else:
            leaf["con"] = con

def check_all_leaves_matched():
    for leaf in leaves:
        if leaf.get("con") is None:
            return False
    return True

async def main():
    sway = await i3ipc.Connection().connect()

    async def on_window(self, event):
        try_match(event.container)
        if check_all_leaves_matched():
            sway.main_quit()
    sway.on("window", on_window)
    event_loop = asyncio.create_task(sway.main())

    for con in await sway.get_tree():
        try_match(con)

    if not check_all_leaves_matched():
        await event_loop

    await asyncio.sleep(1)
    for leaf in leaves:
        await leaf["con"].command("move scratchpad")

    async def apply_layout(subtree):
        applied_split = False
        for node in subtree["nodes"]:
            if con := node.get("con"):
                await con.command("move workspace 1")
                await con.command("floating disable")
                if not applied_split:
                    await con.command("split toggle")
                    await con.command(f"layout {subtree['layout']}")
                    applied_split = True
                await con.command("focus")
            elif children := node.get("nodes"):
                await apply_layout(node)
        if con := subtree["nodes"][0].get("con"):
            await con.command("focus parent")
    await apply_layout(layout)

    for leaf in leaves:
        con = leaf["con"]
        await con.command("focus")
        await con.command(f"resize set {leaf.get('width', 0)} \
                {leaf.get('height', 0)}")
        while leaf := leaf.get("parent"):
            await sway.command("focus parent")
            await sway.command(f"resize set {leaf.get('width', 0)} \
                    {leaf.get('height', 0)}")

    await leaves[0]["con"].command("focus")

asyncio.run(main())
