from agents import Agent, Runner

agent = Agent(name="x", instructions="hi")
result = Runner.run(agent, "do research")  # missing max_turns
result2 = Runner.run_sync(agent, "another task")  # missing max_turns
