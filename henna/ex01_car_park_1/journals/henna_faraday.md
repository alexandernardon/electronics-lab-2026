# Journal � Exercise 1 � Car Park 1

> **You:** `henna_faraday` � **Group:** `henna` � **Opened:** 2026-11-11
> The code in this folder is shared with your group. **This journal is yours alone.**
> Write entries as you work, not after the fact.

---

## Decision log

### Entry � 2026-18-11
**Commit reference:** 931af6e (HEAD -> main, origin/main, origin/HEAD) [IMPL] added clock cycles and the register process

**What I implemented or decided:**
I implemented the arcitecture as 2 processes, like the exercise of the sliding door. A reg process with the current state, the counter and the blink and the FSM that will compute the next state. The FSM has still to be comleted, for now we have a "skeleton" of it with the states. 

**Why I structured it this way:**
Previously we had the clock and the next state-logic in 1 process, then we decided to split it in 2 processes to separate what is "stored" from the FSM and so we could aplly better what we learend in the last exercises. The counter checks next state and not this state, so it's actually 10 cycles and not 11. 

**What I am not sure about:**
For now we have a good plan that we just have to implement, with no real uncertainties, altough I think next time we will find some.

**What the simulation or hardware told me I was wrong about:**
no simulation.

---
<!-- Copy the block above for each significant commit. -->

## Post-submission reflection

**What worked and why:**

**What I would change and why:**
<!-- Be specific. Reference commit hashes. -->

**What assumption did I carry in from the previous exercise that I had to revise here:**
<!-- Required from Exercise 2 onward. -->

**What part of this was my own contribution, and what did I learn from a teammate:**