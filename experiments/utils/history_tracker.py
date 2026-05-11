_STI_HISTORY = {}

def record_cip_series(active_atoms_with_sti):
    global _STI_HISTORY
    
    if not isinstance(active_atoms_with_sti, (list, tuple)):
        return False

    for entry in active_atoms_with_sti:
        atom_name = None
        current_sti = None

        if isinstance(entry, (list, tuple)):
            # Handle the safe (Pair atom sti) format
            if len(entry) >= 3 and str(entry[0]).strip() == "Pair":
                atom_name = str(entry[1]).replace('(', '').replace(')', '').strip()
                try:
                    current_sti = float(entry[2])
                except (ValueError, TypeError):
                    continue
            elif len(entry) >= 2:
                atom_name = str(entry[0]).replace('(', '').replace(')', '').strip()
                try:
                    current_sti = float(entry[1])
                except (ValueError, TypeError):
                    continue
        else:
            # Fallback for stringified expressions
            parts = str(entry).replace('(', '').replace(')', '').replace('[', '').replace(']', '').replace(',', '').replace("'", "").split()
            if len(parts) >= 3 and parts[0] == "Pair":
                atom_name = parts[1]
                try:
                    current_sti = float(parts[2])
                except ValueError:
                    continue
            elif len(parts) >= 2:
                atom_name = parts[0]
                try:
                    current_sti = float(parts[1])
                except ValueError:
                    continue
        
        if atom_name and current_sti is not None:
            if atom_name not in _STI_HISTORY:
                _STI_HISTORY[atom_name] = []
            _STI_HISTORY[atom_name].append(current_sti)
            
    return True

def get_sti_series(atom_name):
    """
    Returns the historical array of STIs for Pearson correlation.
    If the atom has no history yet, returns [0.0] to prevent math crashes.
    """
    global _STI_HISTORY
    
    # Clean the incoming MeTTa atom name just in case it has parenthesis
    name = str(atom_name).replace('(', '').replace(')', '').replace('[', '').replace(']', '').replace("'", "").strip()

    series = _STI_HISTORY.get(name, [0.0])
    # print(f"Retrieving STI series for atom: '{name}':  {series}")
    
    return series

def temporal_conjunction(atom_i, atom_j):
    global _STI_HISTORY
    
    # Clean the incoming names
    name_i = str(atom_i).replace('(', '').replace(')', '').replace('[', '').replace(']', '').replace("'", "").strip()
    name_j = str(atom_j).replace('(', '').replace(')', '').replace('[', '').replace(']', '').replace("'", "").strip()
    
    # Grab the histories (default to [0.0] if empty)
    sti_i = _STI_HISTORY.get(name_i, [0.0])
    sti_j = _STI_HISTORY.get(name_j, [0.0])
    
    if not sti_i or not sti_j:
        return 0.0

    multiplied = [i * j for i, j in zip(sti_i, sti_j)]
    
    if not multiplied:
        return 0.0
    
    # print("calculating temporaal conjunction for", name_i, "and", name_j)
        
    return sum(multiplied) / len(multiplied)