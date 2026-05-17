from agents import Agent, Runner

agent = Agent(name="x", instructions="hi")
result = Runner.run(agent, "do research", timeout=30)  # has timeout
result2 = Runner.run_sync(agent, "task", request_timeout=15)  # has request_timeout
