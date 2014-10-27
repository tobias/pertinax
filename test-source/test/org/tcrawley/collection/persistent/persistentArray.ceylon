import ceylon.test {
    ...
}

import org.tcrawley.collection.persistent {
    ...
}

class A({Object*} contents = {}) => PersistentArray<Object>(contents);

class PersistentArrayTest() {
    test
    shared void testEmptyArray() {
        assert (A().empty);
    }
    
    test
    shared void testInitWithContent() {
        value ary = A({ 1, 2, 3 });
        assertEquals(ary.get(0), 1);
        assertEquals(ary.get(1), 2);
        assertEquals(ary.get(2), 3);
    }
    
    test
    shared void testAppend() {
        value ary = A().append("foo");
        
        assertEquals(ary.get(0), "foo");
        
        value ary2 = ary.append("bar");
        
        assertEquals(ary2.get(0), "foo");
        assertEquals(ary2.get(1), "bar");
        
        assertEquals(ary.get(0), "foo");
        assertEquals(ary.get(1), null);
    }
    
    test
    shared void testAppendAll() {
        value ary = A().appendAll({ "foo", "bar" });
        
        assertEquals(ary.get(0), "foo");
        assertEquals(ary.get(1), "bar");
    }
    
    test
    shared void testRebalance() {
        value ary = A(0..32);
        assertEquals(ary.get(0), 0);
        assertEquals(ary.get(1), 1);
        assertEquals(ary.get(31), 31);
        assertEquals(ary.get(32), 32);
    }
    
    test
    shared void testSet() {
        value ary = A(0..32);
        assertEquals(ary.set(0, 42).get(0), 42);
        assertEquals(ary.set(32, 41).get(32), 41);
    }
    
    test
    shared void testSetNull() {
        value ary = A({ 1 });
        assertNull(ary.set(0, null).get(0));
        assertEquals(ary.get(0), 1);
    }
}
