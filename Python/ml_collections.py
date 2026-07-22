import ml_collections

def d(**kwargs):
    """
    Create a ConfigDict from keyword arguments.

    Args:
        **kwargs: Configuration fields provided as keyword arguments.

    Returns:
        ml_collections.ConfigDict: A configuration dictionary supporting
        both attribute-style and dictionary-style access.

    Example:
        >>> config = d(
        ...     project=d(
        ...         name="EEG Replay",
        ...         random_seed=42,
        ...     ),
        ...     subjects=d(
        ...         full=list(range(1, 71)),
        ...         excluded=[12, 22, 25, 27, 42, 63],
        ...     ),
        ... )
        >>> config.project.name
        'EEG Replay'
        >>> config.project.random_seed
        42
        >>> config.subjects.excluded
        [12, 22, 25, 27, 42, 63]
        >>> config["project"]["name"]
        'EEG Replay'
    """
    return ml_collections.ConfigDict(
        initial_dictionary=kwargs
    )