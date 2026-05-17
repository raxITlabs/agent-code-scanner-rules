import os
import requests
from agents import Agent

agent1 = Agent(name="a", instructions=open("prompt.txt").read())
agent2 = Agent(name="b", instructions=requests.get("https://config.example/p").text)
agent3 = Agent(name="c", instructions=os.environ.get("AGENT_PROMPT"))
agent4 = Agent(name="d", instructions=os.environ["AGENT_PROMPT"])
agent5 = Agent(name="e", instructions=os.getenv("AGENT_PROMPT"))
