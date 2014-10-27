"Provides a persistent immutable array.
 
 The 'modifying' a PersistentArray results in a 
 new object that efficiently shares structure with 
 the previous object."
shared class PersistentArray<Element>({Element*} contents = {}) satisfies List<Element> {
    "Determines the size of the array that backs each node, 
     and is the number of bits of the index that represents each 
     level."
    value scale = 5;
    value nodeSize = 2 ^ scale;
    
    Array<Thing?> newNodeContent<Thing>() => 
            Array<Thing?>({ for (i in 0..(nodeSize - 1)) null });
    
    interface Node of Branch, Leaf {
        shared formal Element|Node? get(Integer localIndex);
        shared formal Node set(Integer localIndex, Element?|Node item);
        shared formal Integer size;
    }
    
    class Leaf(content, size) satisfies Node {
        shared actual Element? get(Integer localIndex) {
            assert (0 <= localIndex < nodeSize);
            return content[localIndex];
        }
        
        string => "``this.content.size`` ``this.content.string``";
        
        shared actual Leaf set(Integer localIndex, Element?|Node item) {
            assert (0 <= localIndex < nodeSize,
                is Element? item);
            value newContent = newNodeContent<Element>();
            this.content.copyTo(newContent);
            newContent.set(localIndex, item);
            return Leaf(newContent,
                localIndex < this.size then this.size else localIndex);
        }
        
        shared actual Integer size;
        Array<Element?> content;
    }
    
    class Branch(content, size) satisfies Node {
        shared actual Node? get(Integer localIndex) {
            assert (0 <= localIndex < nodeSize);
            return content[localIndex];
        }
        shared actual String string => "``this.content.size`` ``this.content.string``";
        
        shared Node getWithCreate(Integer localIndex, Integer level) {
            value node = get(localIndex);
            if (exists node) {
                return node;
            } else if (level == 0) {
                return Leaf(newNodeContent<Element>(), 0);
            } else {
                return Branch(newNodeContent<Node>(), 0);
            }
        }
        
        shared actual Branch set(Integer localIndex, Element?|Node item) {
            assert (0 <= localIndex < nodeSize,
                is Node item);
            value newContent = newNodeContent<Node>();
            this.content.copyTo(newContent);
            newContent.set(localIndex, item);
            return Branch(newContent,
                localIndex < this.size then this.size else localIndex);
        }
        
        shared actual Integer size;
        Array<Node?> content;
    }
    
    class InternalRepresentation(shared Node? root, shared Integer size, shared Integer depth) {
        shared Node assertRoot() {
            assert (is Node root);
            return root;
        }
    }
    
    Integer levelIndex(Integer level, Integer globalIndex) =>
        globalIndex.rightLogicalShift(level * this.scale).and(this.nodeSize - 1);
    
    Node updateWalk(Node node, Integer level, Integer globalIndex, Element? item) {
        value localIndex = levelIndex(level, globalIndex);
        if (level > 0) {
            assert (is Branch node);
            return node.set(localIndex, updateWalk(node.getWithCreate(localIndex, level - 1),
                    level - 1,
                    globalIndex,
                    item));
        } else {
            assert (is Leaf node);
            return node.set(localIndex, item);
        }
    }
    
    //TODO: optimization - do nothing if element == existing entry
    InternalRepresentation internalSet(InternalRepresentation ir,
        Integer index, Element? element) {
        assert (index <= ir.size);
        variable Node currNode = ir.root else Leaf(newNodeContent<Element>(), 0);
        variable Integer depth = ir.depth;
        
        if (index >= this.nodeSize ^ (depth + 1)) {
            currNode = Branch(newNodeContent<Node>(), 0).set(0, currNode);
            depth++;
        }
        
        return InternalRepresentation {
            root  = updateWalk(currNode, depth, index, element);
            size  = index + 1 > ir.size then index + 1 else ir.size;
            depth = depth;
        };
    }
    
    InternalRepresentation internalAppendAll(InternalRepresentation ir, {Element*} elements) =>
            elements.fold<InternalRepresentation>(ir)((InternalRepresentation accum, Element element) =>
                internalSet(accum, accum.size, element));
    
    
    PersistentArray<Element> build(InternalRepresentation newIR) {
        value ary = PersistentArray<Element>();
        ary.ir = newIR;
        return ary;
    }

    
    // actual initializtion
    variable InternalRepresentation ir = InternalRepresentation(null, 0, 0);
    
    if (!contents.empty) {
        //TODO: optimization - implement an accumulating tail array
        this.ir = internalAppendAll(this.ir, contents);
    }
    
    // declarations
    
    // for debugging
    //string => assertIR().root?.string else "empty";
    
    equals(Object that) => (super of List<Element>).equals(that);
    
    /* 
     TODO: we can cache this as part of the IR instead of calculating every time. 
     We can then check hash in equals speed it up (if that is a PersistentArray)
     */
    hash => (super of List<Element>).hash;
    
    size => this.ir.size;
   
    lastIndex => this.size - 1;
    
    clone() => this;
    
    shared actual Element? getFromFirst(Integer index) {
        assert (index >= 0);
        if (this.size > 0 &&
                    index < this.size) {
            value leaf = lookupNode(this.ir.assertRoot(), this.ir.depth, index);
            if (is Leaf leaf) {
    
                return leaf.get(levelIndex(0, index));
            }
        }
        
        return null;
    }

    "Append [[element]] to the end of the array, returning a new array."
    shared PersistentArray<Element> append(Element element) {
        return build(internalSet(this.ir, this.ir.size, element));
    }
    
    "Append [[elements]] to the end of the array in order, returning a new array."
    shared PersistentArray<Element> appendAll({Element*} elements) {
        return elements.empty then this else build(internalAppendAll(this.ir, elements)); 
    }
    
    "Set the entry at [[index]] to [[element]], returning a new array."
    shared PersistentArray<Element> set(Integer index, Element? element) {
        "You can't set an index that doesn't exist."
        assert (index < this.ir.size);
        value ary = PersistentArray<Element>();
        ary.ir = internalSet(this.ir, index, element);
        return ary;
    }
    
    Node? lookupNode(Node? node, Integer level, Integer globalIndex) {
        value localIndex = levelIndex(level, globalIndex);
        if (exists node,
            is Branch node,
            level > 0) {
            return lookupNode(node.get(localIndex), level - 1, globalIndex);
        } else {
            return node;
        }
    }
}
