from agents import function_tool


@function_tool
def search_web(query: str) -> str:
    # no auth / policy check before doing the work
    import urllib.request
    return urllib.request.urlopen(query).read().decode()


@function_tool()
def delete_file(path: str) -> None:
    import os
    os.remove(path)
