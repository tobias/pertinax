import ceylon.test {
    ...
}
import org.tcrawley.collection.persistent {
    ...
}

class L({Object*} contents = {}) => PersistentLinkedList<Object>(contents);

class PersistentLinkedListTest() {
    test
    shared void testEmptyList() {
        assert (L().empty);
    }
    
    test
    shared void testInitWithContent() {
        value list = L({ 1, 2, 3 });
        
        assertEquals(list.get(0), 1);
        assertEquals(list.get(1), 2);
        assertEquals(list.get(2), 3);
    }
    
    test
    shared void testPrepend() {
        value list = L().prepend("foo");
        
        assertEquals(list.first, "foo");
        
        value list2 = list.prepend("bar");
        
        assertEquals(list2.first, "bar");
        assertEquals(list2.get(1), "foo");
        
        assertEquals(list.first, "foo");
        assertEquals(list.get(1), null);
    }
    
    test
    shared void testTail() {
        assert (L().tail.empty);
    }
}
