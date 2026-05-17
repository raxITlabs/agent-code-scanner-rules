from agents import Agent, Runner

agent = Agent(name="x", instructions="hi")
result = Runner.run(agent, "do research")  # missing timeout
result2 = Runner.run_streamed(agent, "task")  # missing timeout
