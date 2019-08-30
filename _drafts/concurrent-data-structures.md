Hold locks for as little as possible
Make sure exceptions don't cause inconsistencies (You can to check anything that could throw an exception). An exception on a thread terminates the application. We can't allow an exception to propagate.
Serialization
