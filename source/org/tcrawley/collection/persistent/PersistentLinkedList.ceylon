shared class PersistentLinkedList<Element>({Element*} content = {}) satisfies List<Element> {
    interface Cell {
        shared formal Element? element;
        shared formal Integer length;
        
        shared formal Cell rest();
    }
    
    object emptyCell satisfies Cell {
        element => null;
        
        length => 0;
        
        shared actual Cell rest() {
            return this;
        }
    }
    
    class NonEmpty(element, length, _rest = emptyCell) satisfies Cell {
        shared actual Element? element;
        shared actual Integer length;
        Cell _rest;
        
        shared actual Cell rest() {
            return this._rest;
        }
    }
    
    Cell internalPrepend(Cell head, Element? element) =>
            NonEmpty(element, head.length + 1, head);
    
    variable Cell _head = emptyCell;
    
    if (!content.empty) {
        this._head = content
            .sequence()
            .reversed
            .fold<Cell>(emptyCell)(internalPrepend);
    }
    
    shared actual Integer lastIndex => this._head.length - 1;
    
    equals(Object that) => (super of List<Element>).equals(that);
    
    hash => (super of List<Element>).hash;
    
    empty => this._head == emptyCell;
    
    shared Element? head => this._head.element;
    
    shared PersistentLinkedList<Element> tail {
        if (this._head != emptyCell) {
            value list = PersistentLinkedList<Element>();
            list._head = _head.rest();
            
            return list;
        }
        
        return PersistentLinkedList<Element>();
    }
    
    shared actual Element? getFromFirst(Integer index) {
        variable value cell = this._head;
        variable value idx = index;
        while (cell != emptyCell && idx > 0) {
            cell = cell.rest();
            idx--;
        }
        
        return cell.element;
    }
    
    shared PersistentLinkedList<Element> prepend(Element? element) {
        value list = PersistentLinkedList<Element>();
        list._head = internalPrepend(this._head, element);
        
        return list;
    }
}
