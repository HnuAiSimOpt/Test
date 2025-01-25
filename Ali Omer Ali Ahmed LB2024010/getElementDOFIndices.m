function dofIndices = getElementDOFIndices(node1, node2, dofPerNode)
    dofIndices = [dofPerNode*(node1-1)+1:dofPerNode*node1, dofPerNode*...
        (node2-1)+1:dofPerNode*node2];
end