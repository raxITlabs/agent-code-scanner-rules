from agents import function_tool


@function_tool
def search_web(query: str, ctx) -> str:
    check_permission(ctx, "web.search")
    import urllib.request
    return urllib.request.urlopen(query).read().decode()


@function_tool()
def delete_file(path: str, ctx) -> None:
    authorize(ctx, "fs.delete", path)
    import os
    os.remove(path)
