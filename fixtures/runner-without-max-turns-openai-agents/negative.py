from agents import Agent, Runner

agent = Agent(name="x", instructions="hi")
result = Runner.run(agent, "do research", max_turns=10)  # has max_turns
result2 = Runner.run_sync(agent, "task", max_turns=5)  # has max_turns
