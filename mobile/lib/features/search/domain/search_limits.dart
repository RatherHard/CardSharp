/// 一次搜索最多展示多少条结果，对齐 `docs/03`「结果限 50 条」。
const int kSearchHitLimit = 50;

/// 点一次「更多搜索结果」增加多少条。
const int kSearchHitLimitStep = kSearchHitLimit;

/// 每页拉取数量。
const int kSearchPageSize = 50;

/// 一次搜索最多扫描多少张卡片；超过就提示用户缩小范围。
const int kSearchScanLimit = 500;
