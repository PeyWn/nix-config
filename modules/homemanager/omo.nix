{
  homeManagerModules.omo = {
    home.file.".omo/agent/skills/grilling/SKILL.md".text = ''
      ---
      name: grilling
      description: Interview the user in decision-tree rounds when a request is unclear, underspecified, or needs its assumptions stress-tested.
      ---

      Interview the user until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

      Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you have not heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

      Format a round like so:

      ```
      Q1 - <question title>: <question body, including multiple choices where useful>

      Recommended answer: <your recommendation>

      ---

      Q2 - <question title>: <question body, including multiple choices where useful>

      Recommended answer: <your recommendation>
      ```

      Word each question so "yes" accepts your recommended answer.

      Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a later round, not this one.

      Finding facts is your job, never the user's. When a frontier question needs a fact from the environment, look it up yourself instead of asking the user. Do not block independent questions on that research. Decisions belong to the user: put each to them and wait.

      The session is done when the frontier is empty: every relevant branch of the design tree visited and nothing material left silently assumed. Do not implement until the user confirms shared understanding.
    '';
  };
}
