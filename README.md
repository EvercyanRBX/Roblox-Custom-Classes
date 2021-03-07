![untitled7](https://user-images.githubusercontent.com/79227558/110228007-36520700-7ec3-11eb-9989-23bf556f1e25.png)


# Roblox-Custom-Classes
A set of free modules you can use for your Roblox games that I created for my upcoming projects, such examples are signal and maid classes which were inspired by Quenty's NevernoreEngine.
I will be adding classes if I think any of them will fit here. Feel free to use them in any way you wish (except for selling them/claiming they are yours, bla bla)! :)

---

## Maid Class

The Maid class is used to make throwing away temporary connections and instances even simpler, and best of all, they are all stored in the Maid module, making it easier to keep track of all of your games garbage.

You 'assign' a task like `Maid:AssignTask(Value, Link)`, where Value would be a Connection/Instance, or even an array of them, and Link would be any Instance (or an array of Instances) that you would like to be used for automatic disconnection/removal of the first argument, `Value`, given.

#### Why might Links be useful you ask?
Say you have a TNT object in Workspace, and in five seconds it will detonate. After these five seconds are up, you would finish the task (More on that later!), right?
The problem here is say the script that this task was created in is a 'temporary script' - say a script under your Character or a Tool, was deleted. Since this task which would store your instances/connections is under the `Tasks` table inside of the maid, these connections (like a Signal) have the chance of staying alive forever.

So when we send a link Instance (usually the script that created the task), if the Instance/script gets deleted before we get the chance to finish the task, it will automatically disconnect/destroy any of the given values.

#### Now that I have created a Task, what can I do with it?

to be finished
