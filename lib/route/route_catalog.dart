/// 路由定義資料類別，描述一個可導頁的應用程式頁面。
class RouteDefinition {
  /// GoRouter 路由路徑，例如 `/home/form-manage`。
  final String path;

  /// 使用者可讀的頁面名稱，例如「表單管理」。
  final String label;

  /// 功能分組，用於 Picker 中的分組標題，例如「表單」、「員工」。
  final String group;

  /// 是否需要透過 `extra` 傳入額外參數才能正常顯示。
  /// 為 `true` 時在 Picker 中顯示警告提示，但不阻擋選取。
  final bool requiresExtra;

  const RouteDefinition({
    required this.path,
    required this.label,
    required this.group,
    this.requiresExtra = false,
  });
}

/// 應用程式路由目錄，集中登錄所有已定義的 GoRouter 路由。
class RouteCatalog {
  const RouteCatalog._();

  /// 留在本頁（不導頁）的虛擬路徑識別碼。
  static const String stayPath = '__stay__';

  /// 返回上一頁的虛擬路徑識別碼。
  static const String backPath = '__back__';

  /// 所有可供導頁行為選擇的路由清單（依分組排列）。
  static const List<RouteDefinition> all = [
    // ── 導頁行為 ──────────────────────────────────────────
    RouteDefinition(
      path: stayPath,
      label: '留在本頁',
      group: '導頁行為',
    ),
    RouteDefinition(
      path: backPath,
      label: '回到上一頁',
      group: '導頁行為',
    ),

    // ── 系統 ─────────────────────────────────────────────
    RouteDefinition(
      path: '/home/main',
      label: '首頁',
      group: '系統',
    ),

    // ── 表單 ─────────────────────────────────────────────
    RouteDefinition(
      path: '/home/form-manage',
      label: '表單管理',
      group: '表單',
    ),
    RouteDefinition(
      path: '/home/form-manage/form-select',
      label: '選擇表單',
      group: '表單',
    ),
    RouteDefinition(
      path: '/home/form-run',
      label: '執行表單',
      group: '表單',
      requiresExtra: true,
    ),
    RouteDefinition(
      path: '/home/form-browse',
      label: '預覽表單',
      group: '表單',
      requiresExtra: true,
    ),

    // ── 組織 ─────────────────────────────────────────────
    RouteDefinition(
      path: '/home/org-manager',
      label: '組織管理',
      group: '組織',
    ),
    RouteDefinition(
      path: '/home/org-manager/org-design-config',
      label: '組織設定',
      group: '組織',
    ),
    RouteDefinition(
      path: '/home/org-manager/org-tree-design',
      label: '組織樹設計',
      group: '組織',
    ),

    // ── 員工 ─────────────────────────────────────────────
    RouteDefinition(
      path: '/home/emp-manager',
      label: '人員管理',
      group: '員工',
    ),
    RouteDefinition(
      path: '/home/emp-manager/guide',
      label: '人員管理指引',
      group: '員工',
    ),
    RouteDefinition(
      path: '/home/emp-agent',
      label: '員工代理人',
      group: '員工',
    ),
    RouteDefinition(
      path: '/home/emp-dep',
      label: '部門管理',
      group: '員工',
    ),
    RouteDefinition(
      path: '/home/emp-info',
      label: '員工資料',
      group: '員工',
    ),
    RouteDefinition(
      path: '/home/emp-role',
      label: '職位設定',
      group: '員工',
    ),
  ];
}
