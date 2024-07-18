const sortByAvailability = () => {
  const desc = sortKey === 'availability' ? !sortDesc : true;
  const sortedPools = [...pools].sort((a, b) => {
    const aValue = getAvailabilityPercentage(a.instances[0]?.capacity.available ?? 0, a.instances[0]?.capacity.total ?? 0);
    const bValue = getAvailabilityPercentage(b.instances[0]?.capacity.available ?? 0, b.instances[0]?.capacity.total ?? 0);
    return desc ? bValue - aValue : aValue - bValue;
  });
  setPools(sortedPools);
  setSortKey('availability');
  setSortDesc(desc);
};

const getAvailabilityPercentage = (available: number, total: number): number => {
  if (total === 0) return 0;
  return Math.round((available / total) * 100);
};
