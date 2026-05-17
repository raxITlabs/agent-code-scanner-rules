from agents import Agent

# Constant string literal under change control = OK
agent1 = Agent(name="a", instructions="You are a helpful assistant.")

# Imported from a versioned module = OK
from prompts import RESEARCH_PROMPT
agent2 = Agent(name="b", instructions=RESEARCH_PROMPT)
