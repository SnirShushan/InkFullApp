<div class="row ink-dash-stats">
    <div class="col-md-3 col-sm-6">
        <a class="ink-stat-card" href="<?= base_url('RegularUsers'); ?>">
            <span class="ink-stat-label"><?= $this->settings['hebrew_text']['Regular Users']; ?></span>
            <span class="ink-stat-value"><?= number_format((int) $stat_regular); ?></span>
        </a>
    </div>
    <div class="col-md-3 col-sm-6">
        <a class="ink-stat-card" href="<?= base_url('BusinessUsers'); ?>">
            <span class="ink-stat-label"><?= $this->settings['hebrew_text']['Business Users']; ?></span>
            <span class="ink-stat-value"><?= number_format((int) $stat_business); ?></span>
        </a>
    </div>
    <div class="col-md-3 col-sm-6">
        <a class="ink-stat-card" href="<?= base_url('ReportOnPosts'); ?>">
            <span class="ink-stat-label">Posts</span>
            <span class="ink-stat-value"><?= number_format((int) $stat_posts); ?></span>
        </a>
    </div>
    <div class="col-md-3 col-sm-6">
        <a class="ink-stat-card" href="<?= base_url('Requests'); ?>">
            <span class="ink-stat-label"><?= $this->settings['hebrew_text']['Requests']; ?></span>
            <span class="ink-stat-value"><?= number_format((int) $stat_requests); ?></span>
        </a>
    </div>
</div>

<style>
.ink-dash-stats { margin-bottom: 8px; }
.ink-stat-card {
    display: block;
    background: #fff;
    border: 1px solid #e4e0ea;
    border-radius: 16px;
    padding: 20px 18px;
    margin-bottom: 18px;
    box-shadow: 0 10px 30px rgba(22, 18, 26, 0.08);
    text-decoration: none !important;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.ink-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 16px 36px rgba(22, 18, 26, 0.12);
}
.ink-stat-label {
    display: block;
    color: #6b676f;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 8px;
}
.ink-stat-value {
    display: block;
    color: #1e1a24;
    font-size: 32px;
    font-weight: 800;
    letter-spacing: -0.03em;
}
</style>
