import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    private lazy var pages: [UIViewController] = {
        
        let blueOnboarding = OnboardingViewController(nibName: nil, bundle: nil, title: "Отслеживайте только то, что хотите", backgroundImage: UIImage(named: "BlueBackground"))
        let redOnboarding = OnboardingViewController(nibName: nil, bundle: nil, title: "Даже если это  не литры воды и йога", backgroundImage: UIImage(named: "RedBackground"))
        
        return [blueOnboarding, redOnboarding]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        pageControl.numberOfPages = pages.count
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 0
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        if previousIndex > 0 && previousIndex < pages.count {
            return pages[previousIndex]
        } else if previousIndex == 0 {
            return pages.first
        } else {
            return pages.last
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex > 0 && nextIndex < pages.count {
            return pages[nextIndex]
        } else if nextIndex == 0 {
            return pages.last
        } else {
            return pages.first
        }
    }
    
    
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
                   let currentIndex = pages.firstIndex(of: currentViewController) {
                    pageControl.currentPage = currentIndex
                }
    }
}
